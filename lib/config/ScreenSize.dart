import 'package:flutter/material.dart';

class ScreenSize {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 650;
  }
}
