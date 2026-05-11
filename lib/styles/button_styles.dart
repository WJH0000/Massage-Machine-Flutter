// lib/styles/button_styles.dart
import 'package:flutter/material.dart';

class ButtonStyles {
  static final ButtonStyle greenButton = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(Colors.green),
    foregroundColor: MaterialStateProperty.all(Colors.white),
    padding: MaterialStateProperty.all(
      EdgeInsets.symmetric(horizontal: 40, vertical: 15),
    ),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  static final ButtonStyle purpleButton = ButtonStyle(
    backgroundColor: MaterialStateProperty.all(Color(0xF6698FFa)),
    foregroundColor: MaterialStateProperty.all(Colors.white),
    padding: MaterialStateProperty.all(
      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    ),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
