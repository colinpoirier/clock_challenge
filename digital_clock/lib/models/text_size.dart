import 'package:digital_clock/constants.dart';
import 'package:flutter/material.dart';

TextSize computeTextSize(double startFont, String text, [double maxWidth]) {
  double fontSize = startFont.truncateToDouble();
  num width = maxWidth?.floor() ?? double.maxFinite;
  TextSpan ts;
  TextPainter tp;

  while (fontSize > 5) {
    ts = TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: kFontFamily,
        fontSize: fontSize,
      ),
    );

    tp = TextPainter(
      text: ts,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    if (tp.width >= width) {
      fontSize -= 1;
    } else {
      break;
    }
  }

  return TextSize(fontSize, tp.height, tp.width);
}

class TextSize {
  TextSize(
    this.fontSize,
    this.fontHeight,
    this.fontWidth,
  );

  final double fontSize;
  final double fontHeight;
  final double fontWidth;

  TextSize operator /(num other) => TextSize(
        fontSize / other,
        fontHeight / other,
        fontWidth / other,
      );

  bool operator ==(Object other) =>
      other is TextSize &&
      fontSize == other.fontSize &&
      fontHeight == other.fontHeight &&
      fontWidth == other.fontWidth;

  @override
  int get hashCode => hashList([fontSize, fontHeight, fontWidth]);

  @override
  String toString() =>
      'fontSize: $fontSize, fontHeight: $fontHeight, fontWidth: $fontWidth';
}
