import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ygc_reports/models/report_model.dart';


/// Defines all business logic related to **databases** which might include
/// methods that is needed and are being used, or methods that are useful
/// and are **expected to be used in the future**.
class ReportRepository {
  static final ReportRepository _instance = ReportRepository._internal();
  factory ReportRepository() => _instance;
  ReportRepository._internal();

  Database? _db;

  /// Returns the database instance.
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  /// Initializes the database when the app launches.
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'reports.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables as OnDatabaseCreateFn,
    );
  }

  /// Create the database tables.
  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE stations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        address TEXT,
        area TEXT,
        supplier TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stationId INTEGER,
        isDraft INTEGER DEFAULT 0,
        isEmptying INTEGER DEFAULT 0,
        date TEXT,
        beginTime TEXT,
        endTime TEXT,
        tankLoad INTEGER,
        inboundAmount INTEGER,
        totalLoad INTEGER,
        remainingLoad INTEGER,
        overflow INTEGER,
        underflow INTEGER,
        filledForPeople INTEGER,
        tanksForPeople INTEGER,
        filledForBuses INTEGER,
        totalConsumed INTEGER,
        notes TEXT,
        workerName TEXT,
        representativeName TEXT,
        workerSignature BLOB,
        representativeSignature BLOB,
        pumpsReadings TEXT,
        FOREIGN KEY(stationId) REFERENCES stations(id) ON DELETE SET NULL
      );
    ''');
  }

  /// Checks if a report exist on a given [date]
  Future<bool> reportExistsOnDate(DateTime date) async {
    final db = await database;

    // Normalize the date to match only the date portion (ignore time)
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    final result = await db.query(
      'reports',
      where: 'date >= ? AND date < ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  /// Returns the latest [ReportModel] saved.
  Future<ReportModel> latestReport() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT reports.*, stations.name AS stationName, stations.address AS stationAddress, stations.area AS stationArea
      FROM reports
      JOIN stations ON reports.stationId = stations.id
      ORDER BY reports.id DESC
      LIMIT 1
    ''');
    
    return _mapToReport(result.first);
  }


  // ---------------------- Stations ----------------------

  /// Inserts a station, many features are expected to be used in the future.
  Future<int> insertStation(String name, {String? address, String? area}) async {
    final db = await database;
    return await db.insert(
      'stations',
      {
        'name': name,
        'address': address,
        'area': area,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Returns a station given its [name]
  Future<Map<String, dynamic>?> getStationByName(String name) async {
    final db = await database;
    final result = await db.query(
      'stations',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Returns all stations in the database.
  Future<List<Map<String, dynamic>>> getAllStations() async {
    final db = await database;
    return await db.query('stations');
  }

  /// Updates a station ;)
  Future<int> updateStation(int id, String name, {String? address, String? area}) async {
    final db = await database;
    return await db.update(
      'stations',
      {'name': name, 'address': address, 'area': area},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes a station :/
  Future<int> deleteStation(int id) async {
    final db = await database;
    return await db.delete(
      'stations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  /// Returns a reprot given its [date], and an optional [isDraft]
  Future<ReportModel?> getReportByDate(DateTime date, {bool isDraft = false}) async {
    final db = await database;

    // Normalize date (remove time part)
    final dateOnly = DateTime(date.year, date.month, date.day);
    final dateString = dateOnly.toIso8601String().substring(0, 10); // 'YYYY-MM-DD'

    // Check for existing report on the same date
    final existing = await db.rawQuery('''
      SELECT reports.*, stations.name as stationName 
      FROM reports
      LEFT JOIN stations ON reports.stationId = stations.id
      WHERE reports.date LIKE ? AND reports.isDraft = ?
      ORDER BY reports.date DESC
      LIMIT 1
    ''', ['$dateString%', isDraft ? 1 : 0]);

    if(existing.isNotEmpty){
      debugPrint("STATION NAME IS: ${existing.first["stationName"]} : ID: ${existing.first["stationId"]}");
      return _mapToReport(existing.first);
    }
    return null;
  }

  // ---------------------- Reports ----------------------

  /// Inserts a report given its [ReportModel], and returns its ID.
  /// ***This will overwrite the report with the same date***
  Future<int> insertReport(ReportModel report) async {
    final db = await database;

    // Get or insert station
    int stationId = await _getOrInsertStation(report.stationName);
    
    final ReportModel? existingReport = await getReportByDate(report.date, isDraft: report.isDraft);
    // If exists, delete it
    if (existingReport != null) {
      final id = existingReport.id as int;
      await db.delete(
        'reports',
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    report.id = null; // To prevent overwriting the previous report if the user has prefilled from.
    // Insert the new report
    return await db.insert(
      'reports',
      _reportToMap(report, stationId),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  

  /// If the station was not found, it inserts it
  Future<int> _getOrInsertStation(String name) async {
    final existing = await getStationByName(name);
    if (existing != null) return existing['id'];
    return await insertStation(name);
  }


  /// Returns the last 30 reports saved in the database.
  Future<List<ReportModel>> getAllReports({bool drafts = false, bool returnAll = true}) async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT reports.*, stations.name as stationName 
      FROM reports
      LEFT JOIN stations ON reports.stationId = stations.id
      ${returnAll? '' : "WHERE isDraft = ${drafts? 1 : 0}"}
      ORDER BY reports.date DESC
      LIMIT 30
    ''');

    final reports = result.map(_mapToReport).toList();
    reports.sort((a, b) => (b.isDraft ? 1 : 0) - (a.isDraft ? 1 : 0));
    return reports;
  }

  /// Updates a report ;/
  Future<int> updateReport(int id, ReportModel report) async {
    final db = await database;
    int stationId = await _getOrInsertStation(report.stationName);
    return await db.update(
      'reports',
      _reportToMap(report, stationId),
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  /// Deletes a report :/
  Future<int> deleteReport(int id) async {
    final db = await database;
    return await db.delete(
      'reports',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes all reports :/
  Future<void> deleteReports() async {
    final db = await database;
    await db.delete(
      'reports',
    );
  }

  // ---------------------- Helpers ----------------------

  Map<String, dynamic> _reportToMap(ReportModel report, int stationId) {
    return {
      'id': report.id,
      'stationId': stationId,
      'date': report.date.toIso8601String(),
      'beginTime': '${report.beginTime.hour}:${report.beginTime.minute}',
      'endTime': '${report.endTime.hour}:${report.endTime.minute}',
      'tankLoad': report.tankLoad,
      'inboundAmount': report.inboundAmount,
      'totalLoad': report.totalLoad,
      'remainingLoad': report.remainingLoad,
      'overflow': report.overflow,
      'underflow': report.underflow,
      'isEmptying': report.isEmptying ? 1 : 0,
      'isDraft': report.isDraft? 1 : 0,
      'filledForPeople': report.filledForPeople,
      'tanksForPeople': report.tanksForPeople,
      'filledForBuses': report.filledForBuses,
      'totalConsumed': report.totalConsumed,
      'notes': report.notes,
      'workerName': report.workerName,
      'representativeName': report.representativeName,
      'workerSignature': report.workerSignature,
      'representativeSignature': report.representativeSignature,
      'pumpsReadings': jsonEncode(report.pumpsReadings),
    };
  }

  ReportModel _mapToReport(Map<String, dynamic> map) {
    final beginParts = (map['beginTime'] as String).split(':');
    final endParts = (map['endTime'] as String).split(':');

    return ReportModel(
      id: map['id'],
      stationName: map['stationName'] ?? "",
      date: DateTime.tryParse(map['date']) ?? DateTime.now(),
      beginTime: TimeOfDay(
        hour: int.tryParse(beginParts[0]) ?? 8,
        minute: int.tryParse(beginParts[1]) ?? 0,
      ),
      endTime: TimeOfDay(
        hour: int.tryParse(endParts[0]) ?? 16,
        minute: int.tryParse(endParts[1]) ?? 0,
      ),
      isEmptying: map['isEmptying'] == 1,
      isDraft: map['isDraft'] == 1,
      tankLoad: map['tankLoad'] ?? 0,
      inboundAmount: map['inboundAmount'] ?? 0,
      totalLoad: map['totalLoad'] ?? 0,
      remainingLoad: map['remainingLoad'] ?? 0,
      overflow: map['overflow'] ?? 0,
      underflow: map['underflow'] ?? 0,
      filledForPeople: map['filledForPeople'] ?? 0,
      tanksForPeople: map['tanksForPeople'] ?? 0,
      filledForBuses: map['filledForBuses'] ?? 0,
      totalConsumed: map['totalConsumed'] ?? 0,
      notes: map['notes'] ?? '',
      workerName: map['workerName'] ?? '',
      representativeName: map['representativeName'] ?? '',
      workerSignature: map['workerSignature'],
      representativeSignature: map['representativeSignature'],
      pumpsReadings: map['pumpsReadings'] != null
          ? List<Map<String, int>>.from(
              (jsonDecode(map['pumpsReadings']) as List).map(
                (e) => Map<String, int>.from(e),
              ),
            )
          : null,
    );
  }
}


/// Here we initialize the database globally only once, and access it from anywhere.
ReportRepository reportRepository = ReportRepository();