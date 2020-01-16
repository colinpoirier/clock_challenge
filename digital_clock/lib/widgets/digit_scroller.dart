import 'package:digital_clock/constants.dart';
import 'package:digital_clock/models/text_size.dart';
import 'package:digital_clock/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DigitScroller extends StatefulWidget {
  DigitScroller.hour(
    this.digit, {
    bool removeZero = false,
    Key key,
  })  : scale = 1.0,
        builder = ((_, index) => (removeZero && index == 0)
            ? const DisplayText('')
            : DisplayText('$index')),
        super(key: key);

  DigitScroller.minute(
    this.digit, {
    Key key,
  })  : scale = 1.0,
        builder = ((_, index) => DisplayText('$index')),
        super(key: key);

  DigitScroller.second(
    this.digit, {
    Key key,
  })  : scale = kFontScale,
        builder = ((_, index) => BodyText('$index')),
        super(key: key);

  final double scale;
  final int digit;
  final IndexedWidgetBuilder builder;

  _DigitScrollerState createState() => _DigitScrollerState();
}

class _DigitScrollerState extends State<DigitScroller> {
  FixedExtentScrollController scrollController;

  int get digit => widget.digit;

  @override
  void initState() {
    super.initState();
    scrollController = FixedExtentScrollController(initialItem: digit);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //Gracefully handle orientation changes
    if (scrollController.hasClients)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Mitigate painting errors of 1 and 2
        scrollController.jumpToItem((digit + 1) % 10);
        animateToDigit();
      });
  }

  @override
  void didUpdateWidget(DigitScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (digit != oldWidget.digit)
      animateToDigit();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void animateToDigit() {
    scrollController.animateToItem(digit,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn);
  }

  @override
  Widget build(BuildContext context) {
    final textSize = Provider.of<TextSize>(context) / widget.scale;
    return Container(
      height: textSize.fontHeight,
      width: textSize.fontWidth,
      child: ListWheelScrollView.useDelegate(
        physics: NeverScrollableScrollPhysics(),
        perspective: kPerspective,
        diameterRatio: 0.5,
        controller: scrollController,
        itemExtent: textSize.fontHeight,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: 10,
          builder: widget.builder,
        ),
      ),
    );
  }
}
