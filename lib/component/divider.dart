import 'package:flutter/material.dart';

class Divider_ extends StatelessWidget {
  final double? height;
  final Color? color;
  Divider_({this.height, this.color});
  @override
  Widget build(BuildContext context) {
    return Divider(
      color: color ?? Colors.transparent,
      height: height,
    );
  }
}
