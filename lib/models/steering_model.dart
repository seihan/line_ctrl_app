import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:line_ctrl_app/enums/steering_display_mode.dart';
import 'package:line_ctrl_app/models/bluetooth_connection_model.dart';
import 'package:line_ctrl_app/models/sensor_model.dart';
import 'package:vector_math/vector_math.dart';

import '../enums/controller_type.dart';
import '../utils.dart';

class SteeringModel extends ChangeNotifier {
  final BluetoothConnectionModel connectionModel;

  SteeringModel({required this.connectionModel});

  static const int upperLimit = 15;
  static const int lowerLimit = -15;
  DateTime? _lastSampleTime;
  static const _samplingInterval = Duration(milliseconds: 80);
  StreamSubscription? _sensorStreamSubscription;
  bool _paused = true;
  bool _showSettings = false;
  bool _showGamepad = false;
  int _leftValue = 0;
  bool _activeLeft = false;
  bool _activeRight = false;
  bool _activePower = false;
  int _rightValue = 0;
  int _powerValue = 0;
  bool _steerLeft = false;
  bool _steerRight = false;

  bool get paused => _paused;
  bool get showSettings => _showSettings;
  bool get showGamepad => _showGamepad;
  int get leftValue => _leftValue;
  int get rightValue => _rightValue;
  int get powerValue => _powerValue;
  bool get activeLeft => _activeLeft;
  bool get activeRight => _activeRight;
  bool get activePower => _activePower;

  set leftValue(int value) {
    if (value != _leftValue) {
      _leftValue = value;
      notifyListeners();
    }
  }

  set rightValue(int value) {
    if (value != _rightValue) {
      _rightValue = value;
      notifyListeners();
    }
  }

  set powerValue(int value) {
    if (value != _powerValue) {
      _powerValue = value;
      notifyListeners();
    }
  }

  SteeringDisplayMode _displayMode = SteeringDisplayMode.controller;
  SteeringDisplayMode _lastDisplayMode = SteeringDisplayMode.controller;

  SteeringDisplayMode get displayMode => _displayMode;

  set displayMode(SteeringDisplayMode value) {
    if (value != _displayMode) {
      _displayMode = value;
      notifyListeners();
    }
  }

  set showSettings(bool value) {
    if (value != _showSettings) {
      _showSettings = value;
      notifyListeners();
    }
  }

  set showGamepad(bool value) {
    if (value != _showGamepad) {
      _showGamepad = value;
      notifyListeners();
    }
  }

  void onPressedSettingsButton() {
    showSettings = !showSettings;
    if (showSettings) {
      displayMode = SteeringDisplayMode.settings;
    } else {
      displayMode = _lastDisplayMode;
    }
  }

  void onOverlaySwitchChanged(bool value) {
    if (value) {
      showGamepad = true;
      displayMode = SteeringDisplayMode.gamepad;
      _lastDisplayMode = SteeringDisplayMode.gamepad;
    } else {
      showGamepad = false;
      displayMode = SteeringDisplayMode.controller;
      _lastDisplayMode = SteeringDisplayMode.controller;
    }
  }

  void onLeftValueChanged(double value) {
    final factor = SensorModel().yFactorLeft;
    leftValue = _scaleNormalizedValue(value, factor: factor) * -1;
    _steerLeft = true;
    _steerRight = false;
    _writeSteering();
  }

  void onRightValueChanged(double value) {
    final factor = SensorModel().yFactorRight;
    rightValue = _scaleNormalizedValue(value, factor: factor);
    _steerRight = true;
    _steerLeft = false;
    _writeSteering();
  }

  void onPowerValueChanged(double value) {
    double factor = 1;
    final isNegative = value < 0;
    isNegative
        ? factor = SensorModel().xFactorBrake
        : SensorModel().xFactorThrottle;
    final scaledValue = _scaleNormalizedValue(value.abs(), factor: factor);
    // Add the sign again
    powerValue = isNegative ? scaledValue * -1 : scaledValue;
    _writeSteering();
  }

  int _scaleNormalizedValue(double value, {double factor = 1}) {
    return Utils.scale(
      value: value,
      inMin: 0,
      inMax: 1,
      outMin: 0,
      outMax: 255 * factor,
    ).toInt();
  }

  void _writeSteering() async {
    if (connectionModel.connected == false) {
      return;
    }
    int steering = 0;
    steering = Utils.deadZone(
      min: -15,
      max: 15,
      value: _steerLeft
          ? leftValue
          : _steerRight
              ? rightValue
              : 0,
    );
    final power = Utils.deadZone(
      min: -15,
      max: 15,
      value: powerValue,
    );
    final msg = Utils.concatSignedInt16Values(steering, power);
    await connectionModel.writeSteering(msg);
  }

  void _initSensorController() {
    _sensorStreamSubscription?.cancel();
    _sensorStreamSubscription = SensorModel().vector2.listen(_handleSensorData);
  }

  void _handleSensorData(Vector2 vector2) async {
    final now = DateTime.now();
    if (connectionModel.connected && !_paused) {
      try {
        if (_lastSampleTime == null ||
            now.difference(_lastSampleTime!) >= _samplingInterval) {
          _lastSampleTime = now;
          // create zero area on both axis
          int steeringValue = Utils.deadZone(
            min: -15,
            max: 15,
            value: vector2.y.toInt(), // single value for both motors
            // negative -> left
            // positive -> right
          );
          final powerValue = Utils.deadZone(
            min: -15,
            max: 15,
            value: -vector2.x.toInt(), // flip the sign
            // negative -> brake
            // positive -> rotate (wind up)
          );
          final msg = Utils.concatSignedInt16Values(steeringValue, powerValue);
          await connectionModel.writeSteering(msg);
        }
      } catch (error) {
        debugPrint(error.toString());
        throw Exception(error);
      }
      notifyListeners();
    }
  }

  void togglePause() {
    _paused = !_paused;
    if (_paused) {
      _sensorStreamSubscription?.cancel();
      _stop();
    } else {
      _initSensorController();
    }
    notifyListeners();
  }

  void _stop() async {
    _rightValue = 0;
    _leftValue = 0;
    _powerValue = 0;
    List<Future> futures = [
      connectionModel.write(
        type: ControllerType.power,
        value: _powerValue,
      ),
      connectionModel.write(
        type: ControllerType.steering,
        value: 0,
      ),
    ];
    await Future.wait(futures);
  }

  bool toggleLeft(bool value) {
    _activeLeft = value;
    if (!_activeLeft) {
      _leftValue = 0;
    }
    connectionModel.connected
        ? connectionModel.write(type: ControllerType.left, value: _leftValue)
        : null;
    notifyListeners();
    return _activeLeft;
  }

  double onChangedLeft(double value) {
    final now = DateTime.now();
    _leftValue = value.toInt();
    _leftValue =
        Utils.deadZone(value: _leftValue, min: lowerLimit, max: upperLimit);
    if (_lastSampleTime == null ||
        now.difference(_lastSampleTime!) >= _samplingInterval) {
      _lastSampleTime = now;
      (_activeLeft && connectionModel.connected)
          ? connectionModel.write(type: ControllerType.left, value: _leftValue)
          : null;
      notifyListeners();
    }
    return value;
  }

  bool toggleRight(bool value) {
    _activeRight = value;
    if (!_activeRight) {
      _rightValue = 0;
    }
    connectionModel.connected
        ? connectionModel.write(type: ControllerType.right, value: _rightValue)
        : null;
    notifyListeners();
    return _activeRight;
  }

  double onChangedRight(double value) {
    final now = DateTime.now();
    _rightValue = value.toInt();
    _rightValue =
        Utils.deadZone(value: _rightValue, min: lowerLimit, max: upperLimit);
    if (_lastSampleTime == null ||
        now.difference(_lastSampleTime!) >= _samplingInterval) {
      _lastSampleTime = now;
      (_activeRight && connectionModel.connected)
          ? connectionModel.write(
              type: ControllerType.right,
              value: _rightValue,
            )
          : null;
      notifyListeners();
    }
    return value;
  }

  bool togglePower(bool value) {
    _activePower = value;
    if (!activePower) {
      _powerValue = 0;
    }
    connectionModel.connected
        ? connectionModel.write(type: ControllerType.power, value: _powerValue)
        : null;
    notifyListeners();
    return _activePower;
  }

  double onChangedPower(double value) {
    final now = DateTime.now();
    _powerValue = value.toInt();
    _powerValue =
        Utils.deadZone(value: _powerValue, min: lowerLimit, max: upperLimit);
    if (_lastSampleTime == null ||
        now.difference(_lastSampleTime!) >= _samplingInterval) {
      _lastSampleTime = now;
      (_activePower && connectionModel.connected)
          ? connectionModel.write(
              type: ControllerType.power,
              value: _powerValue,
            )
          : null;
    }
    notifyListeners();
    return value;
  }

  @override
  void dispose() {
    _sensorStreamSubscription?.cancel();
    super.dispose();
  }
}
