import 'package:flutter/material.dart';

/// A singleton class that manages the settings related to control factors for braking,
/// throttling, and directional steering. It provides getters and setters to modify
/// these factors, which are typically expected to be within the range 0 to 1.
///
/// This model is used to adjust the sensitivity or intensity of different controls,
/// allowing dynamic tuning of the application's behavior at runtime.
class SettingsModel extends ChangeNotifier {
  static final SettingsModel _instance = SettingsModel._internal();
  factory SettingsModel() {
    return _instance;
  }
  SettingsModel._internal();

  // limiter 0 .. 1
  double _factorBrake = 1;
  double _factorThrottle = 1;
  double _factorLeft = 1;
  double _factorRight = 1;

  /// Gets the current brake factor.
  double get factorBrake => _factorBrake;

  /// Gets the current throttle factor.
  double get factorThrottle => _factorThrottle;

  /// Gets the current left steering factor.
  double get factorLeft => _factorLeft;

  /// Gets the current right steering factor.
  double get factorRight => _factorRight;

  /// Sets the brake factor, expected to be within 0..1.
  set factorBrake(double value) {
    if (value != _factorBrake) {
      _factorBrake = value;
      notifyListeners();
    }
  }

  /// Sets the throttle factor, expected to be within 0..1.
  set factorThrottle(double value) {
    if (value != _factorThrottle) {
      _factorThrottle = value;
      notifyListeners();
    }
  }

  /// Sets the left steering factor, expected to be within 0..1.
  set factorLeft(double value) {
    if (value != _factorLeft) {
      _factorLeft = value;
      notifyListeners();
    }
  }

  /// Sets the right steering factor, expected to be within 0..1.
  set factorRight(double value) {
    if (value != _factorRight) {
      _factorRight = value;
      notifyListeners();
    }
  }

  /// Updates the brake factor and returns the new value.
  double onChangedFactorBrake(double value) => factorBrake = value;

  /// Updates the throttle factor and returns the new value.
  double onChangedFactorThrottle(double value) => factorThrottle = value;

  /// Updates the left steering factor and returns the new value.
  double onChangedFactorLeft(double value) => factorLeft = value;

  /// Updates the right steering factor and returns the new value.
  double onChangedFactorRight(double value) => factorRight = value;
}
