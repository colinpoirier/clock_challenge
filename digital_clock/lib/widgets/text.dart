import 'package:flutter/material.dart';

class DisplayText extends StatelessWidget {
  const DisplayText(this.data, {Key key}) : super(key: key);

  final String data;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.display1,
    );
  }
}

class BodyText extends StatelessWidget {
  const BodyText(this.data, {Key key}) : super(key: key);

  final String data;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.body1,
    );
  }
}