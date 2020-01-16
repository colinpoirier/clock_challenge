// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:digital_clock/constants.dart';
import 'package:digital_clock/models/clock_time.dart';
import 'package:digital_clock/models/text_size.dart';
import 'package:digital_clock/widgets/digit_scroller.dart';
import 'package:digital_clock/widgets/single_scoller.dart';
import 'package:digital_clock/widgets/text.dart';
import 'package:digital_clock/widgets/weather_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:provider/provider.dart';

// A basic digital clock.
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  static const lightTheme = [
    Color(0xFF4292FF), //Light blue
    Color(0xFF0D47A1), //Colors.blue.shade900
  ];

  static const darkTheme = [
    Colors.grey,
    Colors.black,
  ];

  static const baseStyle = TextStyle(
    fontFamily: kFontFamily,
    color: Colors.white,
  );

  ClockModel get model => widget.model;

  Color lerpedColor(ClockTime clockTime) {
    final t = clockTime.preciseMinute / 60;
    if (clockTime.hour < 6) return Color.lerp(darkTheme[1], lightTheme[1], t);
    return Color.lerp(darkTheme[1], lightTheme[1], 1 - t);
  }

  String timeLabel(ClockTime clockTime) {
    final hour = clockTime.hour;
    final minute = clockTime.minute;
    final meridiem = clockTime.isAM ? 'a m' : 'p m';
    return '$hour $minute ${clockTime.is24HourFormat ? '' : meridiem}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final is24HourFormat = model.is24HourFormat;
    Provider.of<ClockTime>(context, listen: false).is24HourFormat =
        is24HourFormat;
    return LayoutBuilder(
      builder: (_, constraints) {
        final width = constraints.maxWidth * 1.1;
        final fontGuess = constraints.maxHeight / 2;
        final fontSize = computeTextSize(fontGuess, '00:00:00', width).fontSize;
        double maxFontWidth = 0.0;
        double maxFontHeight = 0.0;
        for (int i = 0; i < 10; i++) {
          final c = computeTextSize(fontSize, '$i');
          if (c.fontHeight > maxFontHeight)
            maxFontHeight = c.fontHeight;
          if (c.fontWidth > maxFontWidth)
            maxFontWidth = c.fontWidth;
        }
        final textSize = TextSize(fontSize, maxFontHeight, maxFontWidth);
        return Consumer<ClockTime>(
          builder: (_, clockTime, child) {
            final value = clockTime.value;
            final isTimeForColor = value < -1 || value > 1;
            return Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              decoration: isTimeForColor
                  ? BoxDecoration(
                      color: !isDark ? lerpedColor(clockTime) : darkTheme[1],
                    )
                  : BoxDecoration(
                      gradient: RadialGradient(
                        radius: 0.5 - value.abs() / 2,
                        center: Alignment(value, math.pow(value, 2)),
                        colors:
                            clockTime.isDay && !isDark ? lightTheme : darkTheme,
                      ),
                    ),
              child: Semantics(
                label: timeLabel(clockTime),
                explicitChildNodes: true,
                child: child,
              ),
            );
          },
          child: Provider<TextSize>.value(
            value: textSize,
            child: Theme(
              data: ThemeData(
                iconTheme: IconThemeData(
                  color: Colors.white,
                  size: textSize.fontSize / kFontScale,
                ),
                textTheme: TextTheme(
                  display1: baseStyle.copyWith(fontSize: textSize.fontSize),
                  body1: baseStyle.copyWith(
                      fontSize: textSize.fontSize / kFontScale),
                ),
              ),
              child: Stack(
                alignment: const Alignment(0, 0.1),
                children: <Widget>[
                  WeatherDisplay(
                    model: model,
                  ),
                  TimeDisplay(
                    textSize: textSize / kFontScale,
                    is24HourFormat: is24HourFormat,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class WeatherDisplay extends StatelessWidget {
  const WeatherDisplay({
    Key key,
    @required this.model,
  }) : super(key: key);

  final ClockModel model;

  String weatherLabel() {
    final condition = model.weatherString;
    final temperature = model.temperature;
    final unit = model.unitString;
    return '$condition $temperature $unit';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 10,
      child: Semantics(
        excludeSemantics: true,
        label: weatherLabel(),
        child: Row(
          children: <Widget>[
            SingleScroller(
              child: WeatherIcon.from(model.weatherCondition),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: SingleScroller(
                child: BodyText(
                  model.temperatureString,
                  key: Key(model.temperatureString),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeDisplay extends StatelessWidget {
  const TimeDisplay({
    Key key,
    @required this.textSize,
    @required this.is24HourFormat,
  }) : super(key: key);

  final TextSize textSize;
  final bool is24HourFormat;

  @override
  Widget build(BuildContext context) {
    final colonWidth = computeTextSize(textSize.fontSize, ':').fontWidth;
    final aWidth = computeTextSize(textSize.fontSize, 'A').fontWidth;
    final pWidth = computeTextSize(textSize.fontSize, 'P').fontWidth;
    final containerWidth = 2 * textSize.fontWidth + colonWidth;
    return ExcludeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Selector<ClockTime, int>(
            selector: (_, time) => time.hour ~/ 10,
            builder: (_, digit, child) =>
                DigitScroller.hour(digit, removeZero: true),
          ),
          Selector<ClockTime, int>(
            selector: (_, time) => time.hour % 10,
            builder: (_, digit, child) => DigitScroller.hour(digit),
          ),
          const DisplayText(':'),
          Selector<ClockTime, int>(
            selector: (_, time) => time.minute ~/ 10,
            builder: (_, digit, child) => DigitScroller.minute(digit),
          ),
          Selector<ClockTime, int>(
            selector: (_, time) => time.minute % 10,
            builder: (_, digit, child) => DigitScroller.minute(digit),
          ),
          Container(
            height: 2 * textSize.fontHeight,
            width: containerWidth,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                if (!is24HourFormat)
                  Selector<ClockTime, bool>(
                    selector: (_, time) => time.isAM,
                    builder: (_, isAM, __) {
                      final meridiem = isAM ? 'A' : 'P';
                      final letterWidth = isAM ? aWidth : pWidth;
                      // Center letter between digits
                      // Works for nearly all fonts
                      // Roboto requires colonWidth += 1  ^^^
                      final x = colonWidth / (containerWidth - letterWidth);
                      return Align(
                        alignment: Alignment(x, -1),
                        child: SingleScroller(
                          child: BodyText(
                            meridiem,
                            key: Key(meridiem),
                          ),
                        ),
                      );
                    },
                  ),
                Row(
                  children: <Widget>[
                    const BodyText(':'),
                    Selector<ClockTime, int>(
                      selector: (_, time) => time.second ~/ 10,
                      builder: (_, digit, child) => DigitScroller.second(digit),
                    ),
                    Selector<ClockTime, int>(
                      selector: (_, time) => time.second % 10,
                      builder: (_, digit, child) => DigitScroller.second(digit),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
