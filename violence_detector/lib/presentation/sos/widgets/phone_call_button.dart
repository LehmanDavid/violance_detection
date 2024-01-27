import 'package:flutter/material.dart';
import 'package:violence_detector/core/services/sos_call_service.dart';
import '../../../core/ui/theme/palette.dart';

class PhoneCallButton extends StatelessWidget {
  static const double _height = 135;
  static const double _padding = 10;
  static const double _borderRadius = 12;
  static const double _smallerTextSize = 14;
  static const double _biggerTextSize = 24;

  const PhoneCallButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Palette.primary100,
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: Material(
        color: Palette.primary100,
        borderRadius: BorderRadius.circular(_borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(_borderRadius),
          onTap: () async => await SOSCallService.launchDialer(),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: _padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  backgroundColor: Palette.primary200,
                  child: Icon(Icons.phone, color: Palette.primary600),
                ),
                Text.rich(
                  TextSpan(
                    text: 'Экстренная оперативная служба\n',
                    style: TextStyle(
                      color: Palette.primary600,
                      fontSize: _smallerTextSize,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: '112',
                        style: TextStyle(
                          color: Palette.primary600,
                          fontSize: _biggerTextSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
