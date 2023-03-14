import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum ControllerType { right, left, power, steering }

class BluetoothConnectionModel {
  final Guid _serviceGuid = Guid('0058545f-5f5f-5f52-4148-435245574f50');
  final Guid _rightCharGuid = Guid('0058545f-5f5f-5f52-4148-435245574f51');
  final Guid _leftCharGuid = Guid('0058545f-5f5f-5f52-4148-435245574f52');
  final Guid _steeringCharGuid = Guid('0058545f-5f5f-5f52-4148-435245574f53');
  final Guid _powerCharGuid = Guid('0058545f-5f5f-5f52-4148-435245574f54');
  final Guid _powerRxCharUuid = Guid('0058545f-5f5f-5f52-4148-435245574f55');
  final FlutterBluePlus _instance = FlutterBluePlus.instance;

  StreamSubscription<List<ScanResult>>? _scanStreamSubscription;
  StreamSubscription<BluetoothDeviceState>? _deviceStreamSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _notifyStreamSubscription;
  BluetoothDevice? _device;
  BluetoothService? _lineService;
  BluetoothCharacteristic? _leftChar;
  BluetoothCharacteristic? _rightChar;
  BluetoothCharacteristic? _powerChar;
  BluetoothCharacteristic? _powerRxChar;
  BluetoothCharacteristic? _steeringChar;
  bool _connected = false;
  bool _isNotifying = false;
  int _leftValue = 0;
  int _rightValue = 0;

  int get leftValue => _leftValue;
  int get rightValue => _rightValue;
  bool get connected => _connected;
  bool get isNotifying => _isNotifying;

  Stream<List<int>>? get notifyStream => _powerRxChar?.value;

  set leftValue(int value) {
    if (value == _leftValue) {
      return;
    }
    _leftValue = value;
  }

  BluetoothConnectionModel() {
    _initialize();
  }

  void _initialize() {
    startScan();
    _listenScanResults();
    _connectionSubscription = Stream.periodic(const Duration(seconds: 5))
        .asyncMap((_) => _instance.connectedDevices)
        .listen(_listenConnections);
  }

  void startScan() {
    debugPrint('start scanning');
    _instance.startScan(timeout: const Duration(seconds: 5));
  }

  void disconnect() {
    _device?.disconnect();
  }

  void _listenScanResults() {
    _scanStreamSubscription = _instance.scanResults.listen(_handleScanResult);
  }

  Future<void> write({int value = 0, required ControllerType type}) async {
    switch (type) {
      case ControllerType.left:
        await _leftChar?.write(
          utf8.encode(value.toString()),
          withoutResponse: true,
        );
        break;
      case ControllerType.right:
        await _rightChar?.write(
          utf8.encode(value.toString()),
          withoutResponse: true,
        );
        break;
      case ControllerType.power:
        await _powerChar?.write(
          utf8.encode(value.toString()),
          withoutResponse: true,
        );
        break;
      case ControllerType.steering:
        await _steeringChar?.write(
          utf8.encode(value.toString()),
          withoutResponse: true,
        );
        break;
    }
  }

  Future<void> toggleNotify() async {
    _isNotifying = !_isNotifying;
    debugPrint('is notifying; ${_powerRxChar?.isNotifying}');

    await _powerRxChar?.setNotifyValue((_powerRxChar?.isNotifying ?? false));
    if (_isNotifying) {
      _notifyStreamSubscription =
          _powerRxChar?.value.listen(_handleNotifyValues);
      await _powerRxChar?.read();
    }
  }

  void _listenConnections(List<BluetoothDevice> event) {
    bool hasConnections = event.isNotEmpty;
    if (_connected != hasConnections) {
      _connected = hasConnections;
    }
  }

  void _handleDeviceState(BluetoothDeviceState? deviceState) async {
    if (deviceState != BluetoothDeviceState.connecting ||
        deviceState != BluetoothDeviceState.connected ||
        deviceState == BluetoothDeviceState.disconnected) {
      try {
        debugPrint('connecting');
        await _device?.connect();
      } catch (e) {
        debugPrint('error: $e');
      } finally {
        _findService(await _device?.discoverServices());
        _connected = true;
      }
    } else {
      _connected = false;
      debugPrint('disconnected');
    }
  }

  void _findService(List<BluetoothService>? services) {
    if (services != null) {
      for (var element in services) {
        debugPrint('${element.uuid}');
        if (element.uuid == _serviceGuid) {
          debugPrint('found line ctrl service');
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
          debugPrint('found left char');
          _leftChar = element;
        }
        if (element.uuid == _rightCharGuid) {
          debugPrint('found right char');
          _rightChar = element;
        }
        if (element.uuid == _powerCharGuid) {
          debugPrint('found power char');
          _powerChar = element;
        }
        if (element.uuid == _powerRxCharUuid) {
          debugPrint('found power rx char');
          _powerRxChar = element;
        }
        if (element.uuid == _steeringCharGuid) {
          debugPrint('found steering char');
          _steeringChar = element;
        }
      }
    }
  }

  void _handleScanResult(List<ScanResult> results) {
    if (results.isNotEmpty) {
      for (var element in results) {
        if (element.device.name == 'LineCtrl') {
          _instance.stopScan();
          debugPrint('found ${element.device.name}');
          _device = element.device;
          _deviceStreamSubscription = _device?.state.listen(_handleDeviceState);
        }
      }
    }
  }

  void _handleNotifyValues(List<int> values) {
    if (values.isNotEmpty) {
      debugPrint('notify values: $values');
    }
  }

  void dispose() {
    _scanStreamSubscription?.cancel();
    _deviceStreamSubscription?.cancel();
    _notifyStreamSubscription?.cancel();
    _connectionSubscription?.cancel();
    _device?.disconnect();
  }
}
