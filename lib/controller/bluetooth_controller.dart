import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';

enum ControllerType { right, left, power }

class BluetoothController {
  StreamSubscription<List<ScanResult>>? _scanStreamSubscription;
  StreamSubscription<BluetoothDeviceState>? _deviceStreamSubscription;
  BluetoothDevice? _device;
  BluetoothService? _lineService;
  BluetoothCharacteristic? _leftChar;
  BluetoothCharacteristic? _powerChar;
  BluetoothCharacteristic? _rightChar;
  final Guid _serviceGuid = Guid("3a39152a-6371-4730-8e24-31be298cf059");
  final Guid _leftCharGuid = Guid("bf3e592d-063b-4b25-884e-5814640054e9");
  final Guid _powerCharGuid = Guid("6cc05bc7-d9da-4b6e-9bfa-65e6c0b5b9d3");
  final Guid _rightCharGuid = Guid("74454618-2b9a-4c9a-bc20-b351dc7bd269");
  bool _connected = false;

  bool get connected => _connected;

  void startScan() {
    debugPrint("start scanning");
    FlutterBlue.instance.startScan(timeout: const Duration(seconds: 5));
  }

  void listenScanResults() {
    _scanStreamSubscription =
        FlutterBlue.instance.scanResults.listen(_handleScanResult);
  }

  Future<void> write({int value = 0, required ControllerType type}) async {
    switch (type) {
      case ControllerType.left:
        await _leftChar?.write(utf8.encode(value.toString()),
            withoutResponse: true);
        break;
      case ControllerType.power:
        await _powerChar?.write(utf8.encode(value.toString()),
            withoutResponse: true);
        break;
      case ControllerType.right:
        await _rightChar?.write(utf8.encode(value.toString()),
            withoutResponse: true);
        break;
    }
  }

  void _handleDeviceState(BluetoothDeviceState? deviceState) async {
    if (deviceState != BluetoothDeviceState.connecting ||
        deviceState != BluetoothDeviceState.connected ||
        deviceState == BluetoothDeviceState.disconnected) {
      try {
        debugPrint("connecting");
        await _device?.connect();
      } catch (e) {
        debugPrint('error: $e');
      } finally {
        _findService(await _device?.discoverServices());
        _connected = true;
      }
    } else {
      _connected = false;
      debugPrint("disconnected");
    }
  }

  void _findService(List<BluetoothService>? services) {
    if (services != null) {
      debugPrint('$services.first.uuid');
      for (var element in services) {
        if (element.uuid == _serviceGuid) {
          debugPrint("found line ctrl service");
          _lineService = element;
          _findCharacteristics(_lineService);
        }
      }
    }
  }

  void _findCharacteristics(BluetoothService? service) {
    if (service != null) {
      for (var element in service.characteristics) {
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

  void _handleScanResult(List<ScanResult> results) {
    if (results.isNotEmpty) {
      for (var element in results) {
        if (element.device.name == "LineCtrl") {
          FlutterBlue.instance.stopScan();
          debugPrint("found ${element.device.name}");
          _device = element.device;
          _deviceStreamSubscription = _device?.state.listen(_handleDeviceState);
        }
      }
    }
  }

  void dispose() {
    _scanStreamSubscription?.cancel();
    _deviceStreamSubscription?.cancel();
    _device?.disconnect();
  }
}
