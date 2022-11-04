import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';

enum ControllerType { right, left, power }

class BluetoothController {
  late final List<StreamSubscription> _streamSubscriptions = [];
  late BluetoothDevice _device;
  late BluetoothService _lineService;
  late BluetoothCharacteristic _leftChar;
  late BluetoothCharacteristic _powerChar;
  late BluetoothCharacteristic _rightChar;
  final Guid _serviceGuid = Guid("3a39152a-6371-4730-8e24-31be298cf059");
  final Guid _leftCharGuid = Guid("bf3e592d-063b-4b25-884e-5814640054e9");
  final Guid _powerCharGuid = Guid("6cc05bc7-d9da-4b6e-9bfa-65e6c0b5b9d3");
  final Guid _rightCharGuid = Guid("74454618-2b9a-4c9a-bc20-b351dc7bd269");
  bool _connected = false;

  final Stream _connectedDevices = Stream.periodic(const Duration(seconds: 2))
      .asyncMap((_) => FlutterBlue.instance.connectedDevices);

  bool get connected => _connected;

  void startScan() {
    debugPrint("start scanning");
    FlutterBlue.instance.startScan(timeout: const Duration(seconds: 5));
  }

  void init() {
    _streamSubscriptions
        .add(FlutterBlue.instance.scanResults.listen(_handleScanResult));
    _streamSubscriptions.add(_connectedDevices.listen(_handleConnectedDevices));
  }

  Future<void> write({int value = 0, required ControllerType type}) async {
    switch (type) {
      case ControllerType.left:
        await _leftChar.write(utf8.encode(value.toString()),
            withoutResponse: true);
        break;
      case ControllerType.power:
        await _powerChar.write(utf8.encode(value.toString()),
            withoutResponse: true);
        break;
      case ControllerType.right:
        await _rightChar.write(utf8.encode(value.toString()),
            withoutResponse: true);
        break;
    }
  }

  void _handleDeviceState(BluetoothDeviceState deviceState) async {
    if (deviceState != BluetoothDeviceState.connecting ||
        deviceState != BluetoothDeviceState.connected ||
        deviceState == BluetoothDeviceState.disconnected) {
      try {
        debugPrint("connecting");
        await _device.connect();
      } catch (e) {
        debugPrint('error: $e');
      } finally {
        _handleServices(await _device.discoverServices());
      }
    } else {
      debugPrint("disconnected");
    }
  }

  void _handleServices(List<BluetoothService> services) {
    if (services.isNotEmpty) {
      debugPrint('$services.first.uuid');
      for (var element in services) {
        if (element.uuid == _serviceGuid) {
          debugPrint("found line ctrl service");
          _lineService = element;
          for (var element in _lineService.characteristics) {
            if (element.uuid == _leftCharGuid) {
              debugPrint("found left char");
              _leftChar = element;
            }
            if (element.uuid == _powerCharGuid) {
              debugPrint("found power char");
              _powerChar = element;
            }
            if (element.uuid == _rightCharGuid) {
              debugPrint("found right char");
              _rightChar = element;
            }
          }
        }
      }
    }
  }

  void _handleScanResult(List<ScanResult> results) {
    if (results.isNotEmpty) {
      for (var element in results) {
        if (element.device.name == "LineCtrl") {
          FlutterBlue.instance.stopScan();
          debugPrint("found " + element.device.name);
          _device = element.device;
          if (_streamSubscriptions.length < 4) {
            _streamSubscriptions.add(_device.state.listen(_handleDeviceState));
          }
        }
      }
    }
  }

  void _handleConnectedDevices(devices) {
    if (devices.isNotEmpty) {
      _connected = true;
    } else {
      _connected = false;
    }
  }

  void dispose() {
    for (var element in _streamSubscriptions) {
      element.cancel();
    }
    _device.disconnect();
  }
}
