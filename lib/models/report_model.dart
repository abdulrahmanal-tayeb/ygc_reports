import 'package:flutter/material.dart';

class ReportModel {
  String stationName;
  DateTime date;
  TimeOfDay beginTime;
  TimeOfDay endTime;

  double currentLoad;
  double inboundLoad;
  double totalLoad;

  double startLiters;
  double endLiters;
  double totalConsumed;

  double remainingLoad;
  double overflow;
  double underflow;

  double filledForPeople;

  String notes;

  String workerName;
  String representativeName;

  ReportModel({
    this.stationName = '',
    DateTime? date,
    TimeOfDay? beginTime,
    TimeOfDay? endTime,
    this.currentLoad = 0,
    this.inboundLoad = 0,
    this.totalLoad = 0,
    this.startLiters = 0,
    this.endLiters = 0,
    this.totalConsumed = 0,
    this.remainingLoad = 0,
    this.overflow = 0,
    this.underflow = 0,
    this.filledForPeople = 0,
    this.notes = '',
    this.workerName = '',
    this.representativeName = '',
  })  : date = date ?? DateTime.now(),
        beginTime = beginTime ?? const TimeOfDay(hour: 8, minute: 0),
        endTime = endTime ?? const TimeOfDay(hour: 16, minute: 0);
}