import 'dart:convert';
import 'dart:developer';
import 'package:alarm/alarm.dart';
import 'package:alarm_app/sp_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AlarmChangeNotifier extends ChangeNotifier {
  AlarmChangeNotifier() {
    onInit();
  }
  Future<void> onInit() async {
    // log('Hello ${alarmList.toString()}');
    alarmList = await SpController().getAlarmList();
    log('in oninit: ${alarmList.toString()}');
    // setAllAlarms();
    notifyListeners();
  }

  List<dynamic> alarmList = [];

  void add(String value) {
    alarmList.add(value);
    notifyListeners();
  }

  final List<String> repeatType = ['Ring once', 'Everyday', 'Sunday-Thusday', 'Custom'];
  final List<String> customDays = ['Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednusday', 'Thusday', 'Friday'];
  final List<String> clockStyle = ['12 Hours', '24 Hours'];

  String getDifference(DateTime alarmTime) {
    if (alarmTime.isBefore(DateTime.now())) {
      Duration duration = const Duration(hours: 24) + alarmTime.difference(DateTime.now());
      return '${duration.inHours.abs()} hours ${duration.inMinutes.remainder(60).abs()} Minutes';
    } else {
      Duration duration = DateTime.now().difference(alarmTime);
      return '${duration.inHours.abs()} hours ${duration.inMinutes.remainder(60).abs()} Minutes';
    }
  }

  final pickedTimeProvider = StateProvider<DateTime>((ref) => DateTime.now());

  final switchProvider = StateProvider.family<bool, int>((ref, index) => true);
  final vibrationSwitchProvider = StateProvider<bool>((ref) => true);
  final checkBoxProvider = StateProvider.family<bool, int>((ref, index) => false);
  final customDaysActionProvider = StateProvider.family<String, int>((ref, index) => '');
  final tempClockStyleState = StateProvider<String>((ref) => '12 Hours');
  final clockStyleState = StateProvider<String>((ref) => '12 Hours');
  String pickedTime = '';
  final tempAlarmActionSelect = StateProvider<String>((ref) => 'Ring once');
  final alarmActionSelect = StateProvider<String>((ref) => 'Ring once');
  String repeatTypeValue = 'Ring once';
  bool vibrationSwitchState = true;
  final ringtoneName = StateProvider<String>((ref) => '');
  String ringtoneNameValue = '';

  String alarmId = '';
  bool switchStateValue = true;
  String clockStyleValue = '12 Hours';
  DateTime selectedDateTime = DateTime.now();
  final isSlidable = StateProvider<bool>((ref) => false);
  // bool themeType=true;
  final themeTypeProvider = StateProvider<bool>((ref) => true);

  void pickTime(time) {
    selectedDateTime = time;
    if (selectedDateTime.isBefore(DateTime.now())) {
      selectedDateTime = selectedDateTime.add(const Duration(days: 1));
    }
    if (clockStyleValue == '12 Hours') {
      pickedTime = DateFormat('h:mm a').format(time);
    } else {
      pickedTime = DateFormat('HH:mm').format(time);
    }
    notifyListeners();
  }

  void saveAlarm(context) async {
    alarmList.clear();
    var id = DateTime.now().millisecondsSinceEpoch % 10000;
    Map<String, dynamic> alarmDetails = {
      "id": id,
      "time": pickedTime,
      "repeat": repeatTypeValue,
      "vibration": vibrationSwitchState,
      "ringtone": ringtoneNameValue,
      "alarmSwitch": true
    };
    // alarmList.add(alarmDetails);
    String encodedMap = json.encode(alarmDetails);
    await SpController().saveAlarmDetails(encodedMap);
    await SpController().saveAlarmList(alarmDetails);
    alarmList = await SpController().getAlarmList();
    // log(alarmList.toString());
    Navigator.pop(context);
    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: selectedDateTime,
      assetAudioPath: ringtoneNameValue == "" ? 'assets/alarm.mp3' : ringtoneNameValue,
      loopAudio: true,
      vibrate: vibrationSwitchState,
      volumeMax: true,
      fadeDuration: 3.0,
      notificationTitle: 'Alarm',
      notificationBody: 'This is the Alarm',
      enableNotificationOnKill: false,
    );
    Alarm.set(alarmSettings: alarmSettings);
    log('in Save Alarm: ${alarmList.toString()}');
    notifyListeners();
  }

  DateTime setAlarmTimeAgain(prevTime) {
    selectedDateTime = DateTime.parse(prevTime);
    if (selectedDateTime.isBefore(DateTime.now())) {
      selectedDateTime = selectedDateTime.add(const Duration(days: 1));
    }
    log(selectedDateTime.toString());
    notifyListeners();
    return selectedDateTime;
  }

  void updateState() {
    notifyListeners();
  }
}