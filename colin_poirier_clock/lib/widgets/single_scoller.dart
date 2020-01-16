import 'dart:math' as math;

import 'package:digital_clock/constants.dart';
import 'package:digital_clock/models/text_size.dart';
import 'package:digital_clock/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_icons/weather_icons.dart' show BoxedIcon;

class SingleScroller extends StatefulWidget {
  final Widget child;

  const SingleScroller({
    Key key,
    this.child,
  }) : super(key: key);

  @override
  _SingleScrollerState createState() => _SingleScrollerState();
}

class _SingleScrollerState extends State<SingleScroller>
    with SingleTickerProviderStateMixin {
  Widget topWidget;
  Widget bottomWidget;

  Widget get child => widget.child;

  AnimationController spinController;
  Animation<double> spinAnimation;

  Size size;
  TextSize textSize;

  @override
  void initState() {
    super.initState();
    topWidget = child;
    textSize = Provider.of<TextSize>(context, listen: false);
    spinController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed)
          setState(() {
            topWidget = bottomWidget;
            bottomWidget = null;
            spinController.reset();
          });
      });
    spinAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(CurvedAnimation(
      parent: spinController,
      curve: Curves.fastOutSlowIn,
    ));
    computeSize();
  }

  @override
  void dispose() {
    spinController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SingleScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (child.key != oldWidget.child.key) {
      if (spinController.isAnimating)
        topWidget = bottomWidget;
      bottomWidget = child;
      computeSize();
      spinController.forward(from: 0);
    }
  }

  void computeSize() {
    final scaled = textSize.fontSize / kFontScale;
    if (child is BoxedIcon) {
      size = Size(scaled * 1.5, scaled + 20);
    } else if (child is BodyText) {
      final data = (child as BodyText).data;
      final tTextSize = computeTextSize(scaled, data);
      size = Size(tTextSize.fontWidth, tTextSize.fontHeight);
    }
  }

  // Thank you open source
  Matrix4 cylinderTransform(double angle) {
    final initialMatrix = MatrixUtils.createCylindricalProjectionTransform(
        angle: angle * math.pi / 2,
        radius: size.height / 3,
        perspective: kPerspective);
    final Matrix4 result = Matrix4.identity();
    final Offset centerOriginTranslation = Alignment.center.alongSize(size);
    result.translate(centerOriginTranslation.dx, centerOriginTranslation.dy);
    result.multiply(initialMatrix);
    result.translate(-centerOriginTranslation.dx, -centerOriginTranslation.dy);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Gracefully handle orientation changes
    final tTextSize = Provider.of<TextSize>(context, listen: false);
    if (textSize != tTextSize) {
      textSize = tTextSize;
      computeSize();
    }
    return Container(
      width: child is BoxedIcon ? size.width : null,
      child: spinAnimation.value < 1.0
          ? Transform(
              transform: cylinderTransform(spinAnimation.value),
              child: topWidget,
            )
          : Transform(
              transform: cylinderTransform(spinAnimation.value - 2),
              child: bottomWidget,
            ),
    );
  }
}
