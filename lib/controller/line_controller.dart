import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:line_ctrl_app/controller/bluetooth_controller.dart';
import 'package:line_ctrl_app/controller/sensor_controller.dart';
import 'package:vector_math/vector_math.dart';

class LineController {
  late final StreamSubscription _sensorStreamSubscription;
  late BluetoothController _bluetoothController;
  late SensorController _sensorController;
  int _bothValue = 0;
  bool _paused = false;

  bool get paused => _paused;

  void init() {
    _initBluetoothController();
    _initSensorController();
  }

  void _initBluetoothController() {
    _bluetoothController = BluetoothController();
    _bluetoothController.init();
    _bluetoothController.startScan();
  }

  void _initSensorController() {
    _sensorController = SensorController();
    _sensorStreamSubscription =
        _sensorController.vector2.listen(_handleSensorData);
  }

  void _handleSensorData(Vector2 vector2) async {
    if (_bluetoothController.connected && !_paused) {
      try {
        if (vector2.x < 2) {
          if (vector2.y < 0) {
            await _bluetoothController.write(
                type: ControllerType.left, value: vector2.y.toInt() * -1);
            await _bluetoothController.write(
                type: ControllerType.right, value: vector2.y.toInt());
          } else {
            await _bluetoothController.write(
                type: ControllerType.left, value: vector2.y.toInt() * -1);
            await _bluetoothController.write(
                type: ControllerType.right, value: vector2.y.toInt());
          }
        } else {
          _bothValue = vector2.x.toInt();
          await _bluetoothController.write(
              type: ControllerType.left, value: _bothValue);
          await _bluetoothController.write(
              type: ControllerType.right, value: _bothValue);
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
          await _bluetoothController.write(
              type: ControllerType.left, value: value);
          break;
        case ControllerType.power:
          await _bluetoothController.write(
              type: ControllerType.power, value: value);
          break;
        case ControllerType.right:
          await _bluetoothController.write(
              type: ControllerType.right, value: value);
          break;
      }
    }
  }

  void togglePause(){
    _paused = !_paused;
  }

  void dispose() {
    _sensorStreamSubscription.cancel();
  }
}
