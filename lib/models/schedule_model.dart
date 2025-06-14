import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'schedule_model.g.dart'; // for generated adapter

@HiveType(typeId: 0)
class ScheduleModel extends HiveObject {
  @HiveField(0)
  int hour;

  @HiveField(1)
  int minute;

  ScheduleModel({required this.hour, required this.minute});

  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);
}
