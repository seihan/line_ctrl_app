import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomErrorHandler {
  static void handleFlutterError(Object error, StackTrace? stackTrace) {
    String errorMessage = 'Flutter: $error';
    // Handle the Flutter error here
    debugPrint('Flutter error: $error');
    debugPrint('Stack trace:\n$stackTrace');
    // You can also show an error message to the user, log the error, etc.
    showToast(errorMessage);
  }

  static void handlePlatformError(Object error, StackTrace stackTrace) {
    String errorMessage = 'Platform error: $error';
    // Handle the platform error here
    debugPrint('Platform error: $error');
    debugPrint('Stack trace:\n$stackTrace');
    // You can also show an error message to the user, log the error, etc.
    showToast(errorMessage);
  }

  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
