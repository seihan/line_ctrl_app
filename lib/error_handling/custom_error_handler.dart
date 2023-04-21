import 'dart:async';

import 'package:flutter/material.dart';

class CustomErrorHandler {
  static final StreamController<String> _streamController =
      StreamController<String>.broadcast();

  static void handleFlutterError(Object error, StackTrace? stackTrace) {
    final String errorMessage = 'Flutter: $error';
    // Handle the Flutter error here
    debugPrint('Flutter error: $error');
    debugPrint('Stack trace:\n$stackTrace');
    _streamController.add(errorMessage);
  }

  static void handlePlatformError(Object error, StackTrace stackTrace) {
    final String errorMessage = 'Platform error: $error';
    // Handle the platform error here
    debugPrint('Platform error: $error');
    debugPrint('Stack trace:\n$stackTrace');
    _streamController.add(errorMessage);
  }

  static Stream<String> get errorStream => _streamController.stream;
}
