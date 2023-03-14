import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:line_ctrl_app/models/bluetooth_connection_model.dart';
import 'package:line_ctrl_app/models/sensor_model.dart';
import 'package:vector_math/vector_math.dart';

class SteeringModel extends ChangeNotifier {
  late BluetoothConnectionModel _connectionModel;
  StreamSubscription? _sensorStreamSubscription;
  late SensorController? _sensorController;
  int _bothValue = 0;
  bool _paused = true;
  int _leftValue = 0;
  int _rightValue = 0;

  bool get paused => _paused;
  int get leftValue => _leftValue;
  int get rightValue => _rightValue;
  bool get connected => _connectionModel.connected;

  SteeringModel() {
    init();
  }

  void init() {
    _connectionModel = BluetoothConnectionModel();
    _initSensorController();
  }

  void _initSensorController() {
    _sensorController = SensorController();
    _sensorStreamSubscription =
        _sensorController?.vector2.listen(_handleSensorData);
  }

  void _handleSensorData(Vector2 vector2) async {
    if (_connectionModel.connected && !_paused) {
      try {
        if (vector2.x < 2) {
          if (vector2.y < 0) {
            await _connectionModel.write(
              type: ControllerType.left,
              value: vector2.y.toInt() * -1,
            );
            await _connectionModel.write(
              type: ControllerType.right,
              value: vector2.y.toInt(),
            );
          } else {
            await _connectionModel.write(
              type: ControllerType.left,
              value: vector2.y.toInt() * -1,
            );
            await _connectionModel.write(
              type: ControllerType.right,
              value: vector2.y.toInt(),
            );
          }
        } else {
          _bothValue = vector2.x.toInt();
          await _connectionModel.write(
            type: ControllerType.left,
            value: _bothValue,
          );
          await _connectionModel.write(
            type: ControllerType.right,
            value: _bothValue,
          );
        }
      } catch (error) {
        debugPrint(error.toString());
      }
    }
  }

  void write({required ControllerType type, int value = 0}) async {
    if (_paused) {
      switch (type) {
        case ControllerType.left:
          await _connectionModel.write(
            type: ControllerType.left,
            value: value,
          );
          break;
        case ControllerType.right:
          await _connectionModel.write(
            type: ControllerType.right,
            value: value,
          );
          break;
        case ControllerType.power:
          await _connectionModel.write(
            type: ControllerType.power,
            value: value,
          );
          break;
        case ControllerType.steering:
          await _connectionModel.write(
            type: ControllerType.steering,
            value: value,
          );
          break;
      }
    }
  }

  void togglePause() {
    _paused = !_paused;
    if (_paused) {
      _sensorStreamSubscription?.cancel();
    } else {
      _initSensorController();
    }
    notifyListeners();
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
    _connectionModel.write(type: ControllerType.left, value: _leftValue);
    notifyListeners();
  }

  void leftRight() {
    _leftValue = _leftValue.abs();
    _connectionModel.write(type: ControllerType.left, value: _leftValue);
    notifyListeners();
  }

  void leftStop() {
    _leftValue = 0;
    _connectionModel.write(type: ControllerType.left, value: _leftValue);
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
    _connectionModel.write(type: ControllerType.right, value: _rightValue);
    notifyListeners();
  }

  void rightRight() {
    _rightValue = _rightValue.abs();
    _connectionModel.write(type: ControllerType.right, value: _rightValue);
    notifyListeners();
  }

  void rightStop() {
    _rightValue = 0;
    _connectionModel.write(type: ControllerType.right, value: _rightValue);
    notifyListeners();
  }

  void toggleNotify() {
    _connectionModel.toggleNotify();
  }

  @override
  void dispose() {
    _sensorStreamSubscription?.cancel();
    _connectionModel.dispose();
    super.dispose();
  }
}
