import 'package:flutter/material.dart';

abstract final class AppTheme {
  const AppTheme._();

  static get theme => ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color.fromARGB(255, 35, 35, 46),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
        iconTheme: const IconThemeData(
          color: Color.fromRGBO(123, 121, 255, 1),
        ),
        colorScheme: const ColorScheme.light(
          primary: Color.fromRGBO(123, 121, 255, 1),
          secondary: Color.fromRGBO(240, 240, 255, 1),
          tertiary: Color.fromRGBO(123, 121, 255, 1),
          error: Colors.deepOrangeAccent,
          background: Colors.white,
        ),
      );
}
