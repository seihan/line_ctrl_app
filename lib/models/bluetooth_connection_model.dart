import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:line_ctrl_app/models/data_package.dart';

import '../error_handling/custom_error_handler.dart';

enum ControllerType { right, left, power, steering }

class BluetoothConnectionModel extends ChangeNotifier {
  final Guid _serviceGuid = Guid('0058545f-5f5f-5f52-4148-435245574f50');
  final Guid _rightCharGuid = Guid('0058545f-5f5f-5f52-4148-435245574f51');
  final Guid _leftCharGuid = Guid('0058545f-5f5f-5f52-4148-435245574f52');
  final Guid _steeringCharGuid = Guid('0058545f-5f5f-5f52-4148-435245574f53');
  final Guid _powerCharGuid = Guid('0058545f-5f5f-5f52-4148-435245574f54');
  final Guid _powerRxCharUuid = Guid('0058545f-5f5f-5f52-4148-435245574f55');
  final FlutterBluePlus _instance = FlutterBluePlus.instance;
  final StreamController<String> _logStream =
      StreamController<String>.broadcast();

  StreamSubscription<List<ScanResult>>? _scanResultSubscription;
  StreamSubscription<BluetoothDeviceState>? _deviceSubscription;
  StreamSubscription<bool>? _scanSubscription;
  StreamSubscription<List<BluetoothDevice>>? _connectionSubscription;
  StreamSubscription? _notifyStreamSubscription;
  BluetoothDevice? _device;
  BluetoothService? _lineService;
  BluetoothCharacteristic? _leftChar;
  BluetoothCharacteristic? _rightChar;
  BluetoothCharacteristic? _powerChar;
  BluetoothCharacteristic? _powerRxChar;
  BluetoothCharacteristic? _steeringChar;
  Timer? _timer;
  DataPackage? _dataPackage;

  bool _connected = false;
  bool _isNotifying = false;
  bool _isScanning = false;
  bool get connected => _connected;
  bool get isNotifying => _isNotifying;
  bool get isScanning => _isScanning;
  DataPackage get data => _dataPackage ?? DataPackage([]);

  Stream<List<int>>? get notifyStream => _powerRxChar?.value;
  Stream<String> get log => _logStream.stream;

  void initialize() {
    startScan();
    _listenScanResults();
    _connectionSubscription = Stream.periodic(const Duration(seconds: 5))
        .asyncMap((_) => _instance.connectedDevices)
        .listen(_listenConnections);
  }

  void startScan() {
    if (_isScanning) {
      return;
    }
    _scanSubscription?.cancel();
    _scanResultSubscription?.cancel();
    _scanResultSubscription = _instance.scanResults.listen(_handleScanResult);
    _scanSubscription = _instance.isScanning.listen(_handleScanState);
    debugPrint('start scanning');
    _instance.startScan(timeout: const Duration(seconds: 5));
  }

  void _handleScanState(bool event) {
    _isScanning = event;
    _logStream.add('is scanning = $event');
    notifyListeners();
  }

  void _listenScanResults() {
    _scanResultSubscription = _instance.scanResults.listen(_handleScanResult);
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
    _logStream.add('is notifying; ${_powerRxChar?.isNotifying}');
    _isNotifying = await _powerRxChar?.setNotifyValue(_isNotifying) ?? false;
    debugPrint('is notifying; ${_powerRxChar?.isNotifying}');
    if (_isNotifying) {
      _notifyStreamSubscription =
          _powerRxChar?.value.listen(_handleNotifyValues);
      await _powerRxChar?.read();
    }
    notifyListeners();
  }

  void _listenConnections(List<BluetoothDevice> event) {
    bool hasConnections = event.isNotEmpty;
    if (_connected != hasConnections) {
      _connected = hasConnections;
    }
  }

  void _handleDeviceState(BluetoothDeviceState? deviceState) async {
    debugPrint('device state = ${deviceState.toString()}');
    _logStream.add('device state = ${deviceState.toString()}');
    if (deviceState != BluetoothDeviceState.connected &&
        deviceState != BluetoothDeviceState.connecting) {
      debugPrint('disconnected');
      _logStream.add('disconnected');
      _connected = false;
      notifyListeners();
      try {
        debugPrint('connecting');
        _logStream.add('connecting');
        await _device?.connect();
        _handleServices(await _device?.discoverServices());
      } on Exception catch (error, stacktrace) {
        CustomErrorHandler.handleFlutterError(error, stacktrace);
        debugPrint('Error: $error');
        _logStream.add('Error: $error');
      }
    } else if (deviceState == BluetoothDeviceState.connecting) {
      debugPrint('is connecting');
      _logStream.add('is connecting');
    } else if (deviceState == BluetoothDeviceState.connected) {
      _connected = true;
      debugPrint('connected');
      _logStream.add('connected');
    }
    notifyListeners();
  }

  void _handleServices(List<BluetoothService>? services) {
    if (services != null) {
      for (var element in services) {
        debugPrint('${element.uuid}');
        if (element.uuid == _serviceGuid) {
          debugPrint('found line ctrl service');
          _logStream.add('found line ctrl service');
          _lineService = element;
          _handleCharacteristics(_lineService);
        }
      }
    }
  }

  void _handleCharacteristics(BluetoothService? service) {
    if (service != null) {
      for (var element in service.characteristics) {
        if (element.uuid == _leftCharGuid) {
          debugPrint('found left char');
          _logStream.add('found left char');
          _leftChar = element;
        }
        if (element.uuid == _rightCharGuid) {
          debugPrint('found right char');
          _logStream.add('found right char');
          _rightChar = element;
        }
        if (element.uuid == _powerCharGuid) {
          debugPrint('found power char');
          _logStream.add('found power char');
          _powerChar = element;
        }
        if (element.uuid == _powerRxCharUuid) {
          debugPrint('found power rx char');
          _logStream.add('found power rx char');
          _powerRxChar = element;
        }
        if (element.uuid == _steeringCharGuid) {
          debugPrint('found steering char');
          _logStream.add('found steering char');
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
          _logStream.add('found ${element.device.name}');
          _device = element.device;
          _deviceSubscription = _device?.state.listen(_handleDeviceState);
        }
      }
    }
  }

  void _handleNotifyValues(List<int> values) {
    if (values.isNotEmpty) {
      _dataPackage = DataPackage(values);
      debugPrint('notify values: ${_dataPackage.toString()}');
      _logStream.add('notify values: ${_dataPackage.toString()}');
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _scanResultSubscription?.cancel();
    _deviceSubscription?.cancel();
    _notifyStreamSubscription?.cancel();
    _connectionSubscription?.cancel();
    _device?.disconnect();
    _timer?.cancel();
    super.dispose();
  }
}
