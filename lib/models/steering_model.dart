import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:line_ctrl_app/models/bluetooth_connection_model.dart';
import 'package:line_ctrl_app/models/sensor_model.dart';
import 'package:vector_math/vector_math.dart';

class SteeringModel extends ChangeNotifier {
  final BluetoothConnectionModel connectionModel;
  StreamSubscription? _sensorStreamSubscription;
  late SensorController? _sensorController;
  bool _paused = true;
  int _leftValue = 0;
  int _rightValue = 0;
  int _powerValue = 0;

  bool get paused => _paused;
  int get leftValue => _leftValue;
  int get rightValue => _rightValue;
  int get powerValue => _powerValue;

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
    }
  }

  void togglePause() {
    _paused = !_paused;
    if (_paused) {
      _stop();
      _sensorStreamSubscription?.cancel();
    } else {
      _initSensorController();
    }
    notifyListeners();
  }

  void _stop() async {
    await connectionModel.write(
      type: ControllerType.right,
      value: 0,
    );
    await connectionModel.write(
      type: ControllerType.left,
      value: 0,
    );
  }

  void leftUp() {
    if (_leftValue < 255) {
      _leftValue = _leftValue + 5;
      notifyListeners();
    }
  }

  void leftDown() {
    if (_leftValue > -255) {
      _leftValue = leftValue - 5;
      notifyListeners();
    }
  }

  void leftLeft() {
    _leftValue = -(_leftValue.abs());
    connectionModel.write(type: ControllerType.left, value: _leftValue);
    notifyListeners();
  }

  void leftRight() {
    _leftValue = _leftValue.abs();
    connectionModel.write(type: ControllerType.left, value: _leftValue);
    notifyListeners();
  }

  void leftStop() {
    _leftValue = 0;
    connectionModel.write(type: ControllerType.left, value: _leftValue);
    notifyListeners();
  }

  void rightUp() {
    if (_rightValue < 255) {
      _rightValue = rightValue + 5;
      notifyListeners();
    }
  }

  void rightDown() {
    if (_rightValue > -255) {
      _rightValue = rightValue - 5;
      notifyListeners();
    }
  }

  void rightLeft() {
    _rightValue = -(_rightValue.abs());
    connectionModel.write(type: ControllerType.right, value: _rightValue);
    notifyListeners();
  }

  void rightRight() {
    _rightValue = _rightValue.abs();
    connectionModel.write(type: ControllerType.right, value: _rightValue);
    notifyListeners();
  }

  void rightStop() {
    _rightValue = 0;
    connectionModel.write(type: ControllerType.right, value: _rightValue);
    notifyListeners();
  }

  void powerUp() {
    if (_powerValue < 255) {
      _powerValue = _powerValue + 5;
      notifyListeners();
    }
  }

  void powerDown() {
    if (_powerValue > -255) {
      _powerValue = _powerValue - 5;
      notifyListeners();
    }
  }

  void powerForward() {
    _powerValue = -(_powerValue.abs());
    connectionModel.write(type: ControllerType.power, value: _powerValue);
    notifyListeners();
  }

  void powerBackward() {
    _powerValue = _powerValue.abs();
    connectionModel.write(type: ControllerType.power, value: _powerValue);
    notifyListeners();
  }

  void powerStop() {
    _powerValue = 0;
    connectionModel.write(type: ControllerType.power, value: _powerValue);
    notifyListeners();
  }

  @override
  void dispose() {
    _sensorStreamSubscription?.cancel();
    super.dispose();
  }
}
