import 'dart:async';

import 'package:flutter/cupertino.dart';
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
  int _leftValue = 0;
  bool _activeLeft = false;
  bool _activeRight = false;
  bool _activePower = false;
  int _rightValue = 0;
  int _powerValue = 0;

  bool get paused => _paused;
  bool get showSettings => _showSettings;
  int get leftValue => _leftValue;
  int get rightValue => _rightValue;
  int get powerValue => _powerValue;
  bool get activeLeft => _activeLeft;
  bool get activeRight => _activeRight;
  bool get activePower => _activePower;

  set showSettings(bool value) {
    if (value != _showSettings) {
      _showSettings = value;
      notifyListeners();
    }
  }

  void onPressedSettingsButton() => showSettings = !showSettings;

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
