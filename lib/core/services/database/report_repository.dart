import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ygc_reports/models/report_model.dart';

class ReportRepository {
  static final ReportRepository _instance = ReportRepository._internal();
  factory ReportRepository() => _instance;
  ReportRepository._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'reports.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables as OnDatabaseCreateFn,
    );
  }

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

  Future<Map<String, dynamic>?> latestReport() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT reports.*, stations.name AS stationName, stations.address AS stationAddress, stations.area AS stationArea
      FROM reports
      JOIN stations ON reports.stationId = stations.id
      ORDER BY reports.id DESC
      LIMIT 1
    ''');

    return result.first;
  }

  // ---------------------- Stations ----------------------

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

  Future<List<Map<String, dynamic>>> getAllStations() async {
    final db = await database;
    return await db.query('stations');
  }

  Future<int> updateStation(int id, String name, {String? address, String? area}) async {
    final db = await database;
    return await db.update(
      'stations',
      {'name': name, 'address': address, 'area': area},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteStation(int id) async {
    final db = await database;
    return await db.delete(
      'stations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------------------- Reports ----------------------

  Future<int> insertReport(ReportModel report) async {
    final db = await database;

    // Get or insert station
    int stationId = await _getOrInsertStation(report.stationName);

    // Normalize date (remove time part)
    final dateOnly = DateTime(report.date.year, report.date.month, report.date.day);
    final dateString = dateOnly.toIso8601String().substring(0, 10); // 'YYYY-MM-DD'

    // Check for existing report on the same date
    final existing = await db.query(
      'reports',
      where: "date LIKE ?",
      whereArgs: ['$dateString%'], // Match any time on the same date
      limit: 1,
    );

    // If exists, delete it
    if (existing.isNotEmpty) {
      final id = existing.first['id'] as int;
      await db.delete(
        'reports',
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    // Insert the new report
    return await db.insert(
      'reports',
      _reportToMap(report, stationId),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  

  Future<int> _getOrInsertStation(String name) async {
    final existing = await getStationByName(name);
    if (existing != null) return existing['id'];
    return await insertStation(name);
  }


  Future<List<ReportModel>> getAllReports() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT reports.*, stations.name as stationName 
      FROM reports
      LEFT JOIN stations ON reports.stationId = stations.id
      ORDER BY reports.date DESC
    ''');

    return result.map(_mapToReport).toList();
  }

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

  Future<int> deleteReport(int id) async {
    final db = await database;
    return await db.delete(
      'reports',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteReports() async {
    final db = await database;
    await db.delete(
      'reports',
    );
  }

  // ---------------------- Helpers ----------------------

  Map<String, dynamic> _reportToMap(ReportModel report, int stationId) {
    return {
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
      stationName: map['stationName'],
      date: DateTime.tryParse(map['date']) ?? DateTime.now(),
      beginTime: TimeOfDay(
        hour: int.tryParse(beginParts[0]) ?? 8,
        minute: int.tryParse(beginParts[1]) ?? 0,
      ),
      endTime: TimeOfDay(
        hour: int.tryParse(endParts[0]) ?? 16,
        minute: int.tryParse(endParts[1]) ?? 0,
      ),
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


ReportRepository reportRepository = ReportRepository();