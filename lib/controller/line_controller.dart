import 'dart:async';

import 'package:line_ctrl_app/controller/bluetooth_controller.dart';
import 'package:line_ctrl_app/controller/sensor_controller.dart';
import 'package:vector_math/vector_math.dart';

class LineController {
  late final StreamSubscription _sensorStreamSubscription;
  late final StreamSubscription _connectionState;
  late BluetoothController _bluetoothController;
  late SensorController _sensorController;
  late Timer _timer;
  bool _send = false;
  bool _connected = false;
  bool _left = false;
  int _bothValue = 0;
  bool paused = false;

  void init() {
    _initBluetoothController();
    _initSensorController();
    _connectionState =
        _bluetoothController.connected.listen(_handleConnectionState);
    _timer = Timer.periodic(const Duration(milliseconds: 50), _timerCallback);
  }

  void _timerCallback(Timer timer) {
    _send = true;
    _left = !_left;
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

  void _handleConnectionState(bool state) async {
    _connected = state;
  }

  void _handleSensorData(Vector2 vector2) async {
    if (_connected && _send && !paused) {
      if (vector2.x < 2) {
        if (vector2.y < 0) {
          if (_left) {
            _bluetoothController.write(
                type: ControllerType.left, value: vector2.y.toInt() * -1);
          } else {
            _bluetoothController.write(
                type: ControllerType.right, value: vector2.y.toInt());
          }
        } else {
          if (_left) {
            _bluetoothController.write(
                type: ControllerType.left, value: vector2.y.toInt() * -1);
          } else {
            _bluetoothController.write(
                type: ControllerType.right, value: vector2.y.toInt());
          }
        }
      } else {
        if (_left) {
          _bothValue = vector2.x.toInt();
          _bluetoothController.write(
              type: ControllerType.left, value: _bothValue);
        } else {
          _bluetoothController.write(
              type: ControllerType.right, value: _bothValue);
        }
      }
      _send = false;
    }
  }

  void write({required ControllerType type, int value = 0}) {
    if (_send) {
      switch (type) {
        case ControllerType.left:
          _bluetoothController.write(type: ControllerType.left, value: value);
          break;
        case ControllerType.power:
          _bluetoothController.write(type: ControllerType.power, value: value);
          break;
        case ControllerType.right:
          _bluetoothController.write(type: ControllerType.right, value: value);
          break;
      }
    }
  }

  void dispose() {
    _sensorStreamSubscription.cancel();
    _connectionState.cancel();
    _timer.cancel();
  }
}
