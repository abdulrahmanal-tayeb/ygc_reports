import 'dart:typed_data';

import 'package:flutter/material.dart';

class ReportModel {
  String stationName;
  DateTime date;
  TimeOfDay beginTime;
  TimeOfDay endTime;

  int tankLoad;
  int inboundAmount;
  int totalLoad;


  List<Map<String, int>>? pumpsReadings;
  int totalConsumed;

  int remainingLoad;
  int overflow;
  int underflow;

  int filledForPeople;
  int tanksForPeople;
  int filledForBuses;

  String notes;

  String workerName;
  String representativeName;

  Uint8List? workerSignature;
  Uint8List? representativeSignature;

  ReportModel({
    this.stationName = '',
    DateTime? date,
    TimeOfDay? beginTime,
    TimeOfDay? endTime,
    this.tankLoad = 0,
    this.inboundAmount = 0,
    this.totalLoad = 0,
    this.remainingLoad = 0,
    this.overflow = 0,
    this.underflow = 0,
    this.filledForPeople = 0,
    this.notes = '',
    this.workerName = '',
    this.pumpsReadings,
    this.tanksForPeople = 0,
    this.filledForBuses = 0,
    this.totalConsumed = 0,
    this.representativeName = '',
    this.representativeSignature,
    this.workerSignature
  })  : date = date ?? DateTime.now(),
        beginTime = beginTime ?? const TimeOfDay(hour: 8, minute: 0),
        endTime = endTime ?? const TimeOfDay(hour: 16, minute: 0);
}