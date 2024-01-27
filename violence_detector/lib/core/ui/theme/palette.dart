import 'package:flutter/painting.dart';

abstract final class Palette {
  const Palette._();

  static const Color primary100 = Color.fromRGBO(240, 240, 255, 1);
  static const Color primary200 = Color.fromRGBO(217, 216, 255, 1);
  static const Color primary500 = Color.fromRGBO(123, 121, 255, 1);
  static const Color primary600 = Color.fromRGBO(73, 69, 255, 1);
  static const Color primary700 = Color.fromRGBO(39, 31, 224, 1);

  static const Color neutral100 = Color.fromRGBO(220, 220, 228, 1);
  static const Color neutral400 = Color.fromRGBO(108, 117, 125, 1);
  static const Color neutral500 = Color.fromRGBO(73, 80, 87, 1);
  static const Color neutral600 = Color.fromRGBO(73, 80, 87, 1);
}
