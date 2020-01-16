import 'dart:async' show Timer;

import 'package:flutter/foundation.dart' show ChangeNotifier;

// Switch comments for speed
class ClockTime extends ChangeNotifier {
  DateTime _dateTime;
  // DateTime _dateTime = DateTime.now();

  double preciseMinute;
  double preciseHour;

  double value = -1;

  Timer timer;

  bool is24HourFormat;

  void updateTime() {
    _dateTime = DateTime.now();
    // _dateTime = _dateTime.add(Duration(seconds: 10));

    preciseMinute = minute + second / 60;
    preciseHour = _dateTime.hour + preciseMinute / 60;

    value = computeValue();

    notifyListeners();

    timer = Timer(
      const Duration(seconds: 1) -
          Duration(milliseconds: _dateTime.millisecond),
      updateTime,
    );
    // timer = Timer(
    // Duration(milliseconds: 5),
    // updateTime,
    // );
  }

  double computeValue() {
    if (preciseHour >= 6 && preciseHour <= 18) return preciseHour / 6 - 2;
    if (preciseHour > 18) return preciseHour * 0.2 - 4.8;
    return preciseHour * 0.2;
  }

  bool get isAM => _dateTime.hour < 12;
  bool get isDay => _dateTime.hour >= 6 && _dateTime.hour <= 18;

  int get second => _dateTime.second;
  int get minute => _dateTime.minute;
  int get hour {
    if (is24HourFormat) return _dateTime.hour;
    final hourModulo12 = _dateTime.hour % 12;
    if (hourModulo12 == 0) return 12;
    return hourModulo12;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
