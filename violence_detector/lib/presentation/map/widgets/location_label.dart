import 'package:flutter/material.dart';

class LocationLabel extends StatelessWidget {
  static const double _boxHeight = 60;
  static const double _padding = 16;
  static const double _textSize = 16;

  static const LinearGradient _linearGradient = LinearGradient(
    begin: Alignment(0.00, -0.6),
    end: Alignment(0, 0.6),
    colors: [
      Color(0xFFFFFFFF),
      Color.fromARGB(27, 217, 217, 217),
    ],
  );

  final String locationName;

  const LocationLabel({
    super.key,
    required this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _boxHeight,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: _padding,
      ),
      decoration: const BoxDecoration(gradient: _linearGradient),
      child: Text(
        locationName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: _textSize,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
