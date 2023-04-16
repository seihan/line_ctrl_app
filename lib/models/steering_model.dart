import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:line_ctrl_app/models/bluetooth_connection_model.dart';
import 'package:line_ctrl_app/models/sensor_model.dart';
import 'package:vector_math/vector_math.dart';

import '../utils.dart';

class SteeringModel extends ChangeNotifier {
  final BluetoothConnectionModel connectionModel;
  StreamSubscription? _sensorStreamSubscription;
  late SensorController? _sensorController;
  bool _paused = true;
  int _leftValue = 0;
  bool _activeLeft = false;
  bool _activeRight = false;
  bool _activePower = false;
  int _rightValue = 0;
  int _powerValue = 0;

  bool get paused => _paused;
  int get leftValue => _leftValue;
  int get rightValue => _rightValue;
  int get powerValue => _powerValue;
  bool get activeLeft => _activeLeft;
  bool get activeRight => _activeRight;
  bool get activePower => _activePower;

  SteeringModel({required this.connectionModel}) {
    init();
  }

  void init() {
    _initSensorController();
  }

  void _initSensorController() {
    _sensorController = SensorController();
    _sensorStreamSubscription =
        _sensorController?.vector2.listen(_handleSensorData);
  }

  void _handleSensorData(Vector2 vector2) async {
    if (connectionModel.connected && !_paused) {
      _leftValue = vector2.y.toInt();
      _rightValue = -vector2.y.toInt();
      _powerValue = vector2.x.toInt();
      _leftValue = Utils.deadZone(value: _leftValue, min: -15, max: 15);
      _rightValue = Utils.deadZone(value: _rightValue, min: -15, max: 15);
      _powerValue = Utils.deadZone(value: _powerValue, min: -15, max: 15);
      try {
        await connectionModel.write(
          type: ControllerType.steering,
          value: vector2.y.toInt(),
        );
        await connectionModel.write(
          type: ControllerType.power,
          value: vector2.x.toInt(),
        );
      } catch (error) {
        debugPrint(error.toString());
      }
      notifyListeners();
    }
  }

  void togglePause() async {
    _paused = !_paused;
    if (_paused) {
      await _sensorStreamSubscription?.cancel();
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
    _leftValue = value.toInt();
    _leftValue = Utils.deadZone(value: _leftValue, min: -15, max: 15);
    (_activeLeft && connectionModel.connected)
        ? connectionModel.write(type: ControllerType.left, value: _leftValue)
        : null;
    notifyListeners();
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
    _rightValue = value.toInt();
    _rightValue = Utils.deadZone(value: _rightValue, min: -15, max: 15);
    (_activeRight && connectionModel.connected)
        ? connectionModel.write(type: ControllerType.right, value: _rightValue)
        : null;
    notifyListeners();
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
    _powerValue = value.toInt();
    _powerValue = Utils.deadZone(value: _powerValue, min: -15, max: 15);
    (_activePower && connectionModel.connected)
        ? connectionModel.write(type: ControllerType.power, value: _powerValue)
        : null;
    notifyListeners();
    return value;
  }

  @override
  void dispose() {
    _sensorStreamSubscription?.cancel();
    super.dispose();
  }
}
