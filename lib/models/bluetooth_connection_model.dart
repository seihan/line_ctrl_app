import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:line_ctrl_app/models/bluetooth_notification_handler.dart';
import 'package:line_ctrl_app/models/data_package.dart';

import '../enums/controller_type.dart';
import '../error_handling/custom_error_handler.dart';
import '../ui/widgets/bluetooth_alert_dialog.dart';

class BluetoothConnectionModel extends ChangeNotifier {
  final GlobalKey<NavigatorState> navigatorKey;
  BluetoothConnectionModel({required this.navigatorKey});

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
  StreamSubscription<String>? _errorSubscription;
  StreamSubscription? _stateSubscription;
  BluetoothDevice? _device;
  BluetoothService? _lineService;
  BluetoothCharacteristic? _leftChar;
  BluetoothCharacteristic? _rightChar;
  BluetoothCharacteristic? _powerChar;
  BluetoothCharacteristic? _powerRxChar;
  BluetoothCharacteristic? _steeringChar;
  DataPackage? _dataPackage;

  bool _connected = false;
  bool _isNotifying = false;
  bool _isScanning = false;
  BluetoothState _state = BluetoothState.unknown;
  bool get connected => _connected;
  bool get isNotifying => _isNotifying;
  bool get isScanning => _isScanning;
  DataPackage get data => _dataPackage ?? DataPackage([]);
  BluetoothState get state => _state;

  Stream<List<int>>? get notifyStream => _powerRxChar?.value;
  Stream<String> get log => _logStream.stream;

  void initialize() {
    _errorSubscription = CustomErrorHandler.errorStream.listen(_onError);
    _stateSubscription = _instance.state.listen(_listenBluetoothState);
    _connectionSubscription = Stream.periodic(const Duration(seconds: 5))
        .asyncMap((_) => _instance.connectedDevices)
        .listen(_listenConnections);
    if (_state == BluetoothState.on) {
      startScan();
    }
  }

  void _onError(String error) {
    if (error.isNotEmpty) {
      _logStream.add('${DateTime.now()} $error');
    }
  }

  void _listenBluetoothState(BluetoothState event) {
    _state = event;
    if (_state == BluetoothState.off && navigatorKey.currentState != null) {
      showDialog(
        context: navigatorKey.currentState!.overlay!.context,
        builder: (BuildContext context) {
          return const BluetoothAlertDialog();
        },
      );
    }
    notifyListeners();
  }

  void startScan() {
    if (_isScanning) {
      return;
    }
    _scanSubscription?.cancel();
    _scanResultSubscription?.cancel();
    _scanResultSubscription = _instance.scanResults.listen(_onScanResult);
    _scanSubscription = _instance.isScanning.listen(_handleScanState);
    debugPrint('start scanning');
    _instance.startScan(timeout: const Duration(seconds: 5));
  }

  void _handleScanState(bool event) {
    _isScanning = event;
    _logStream.add('is scanning = $event');
    notifyListeners();
  }

  Future<void> write({int value = 0, required ControllerType type}) async {
    switch (type) {
      case ControllerType.left:
        await _leftChar?.write(
          utf8.encode(value.toString()),
          withoutResponse: false,
        );
        break;
      case ControllerType.right:
        await _rightChar?.write(
          utf8.encode(value.toString()),
          withoutResponse: false,
        );
        break;
      case ControllerType.power:
        await _powerChar?.write(
          utf8.encode(value.toString()),
          withoutResponse: false,
        );
        break;
      case ControllerType.steering:
        await _steeringChar?.write(
          utf8.encode(value.toString()),
          withoutResponse: false,
        );
        break;
    }
  }

  Future<void> toggleNotify() async {
    _isNotifying = !_isNotifying;
    if (!_isNotifying) {
      _notifyStreamSubscription?.cancel();
    }
    final BluetoothNotificationHandler notificationHandler =
        BluetoothNotificationHandler(
      powerRxChar: _powerRxChar,
      setNotify: _isNotifying,
    );
    notificationHandler.startNotifications()?.listen(_handleNotifyValues);
    _logStream.add('is notifying; ${notificationHandler.isNotifying}');
    debugPrint('is notifying; ${notificationHandler.isNotifying}');
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

  void _onScanResult(List<ScanResult> results) {
    if (results.isNotEmpty && _device == null) {
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
    _errorSubscription?.cancel();
    _stateSubscription?.cancel();
    super.dispose();
  }
}
