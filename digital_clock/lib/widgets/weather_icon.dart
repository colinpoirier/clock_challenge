import 'package:flutter/material.dart' show IconData, Key;
import 'package:flutter_clock_helper/model.dart' show WeatherCondition;
import 'package:weather_icons/weather_icons.dart';

class WeatherIcon {
  static IconData iconDataFromWeather(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.sunny:
        return WeatherIcons.day_sunny;
      case WeatherCondition.cloudy:
        return WeatherIcons.cloudy;
      case WeatherCondition.foggy:
        return WeatherIcons.fog;
      case WeatherCondition.rainy:
        return WeatherIcons.rain;
      case WeatherCondition.snowy:
        return WeatherIcons.snow;
      case WeatherCondition.thunderstorm:
        return WeatherIcons.thunderstorm;
      case WeatherCondition.windy:
        return WeatherIcons.strong_wind;
      default:
        return WeatherIcons.na;
    }
  }

  static BoxedIcon from(WeatherCondition condition) => BoxedIcon(
        iconDataFromWeather(condition),
        key: Key('$condition'),
      );
}
