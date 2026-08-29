import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:line_ctrl_app/models/bluetooth_notification_handler.dart';
import 'package:line_ctrl_app/models/permission_model.dart';
import 'package:line_ctrl_app/models/vesc_state_model.dart';
import 'package:line_ctrl_app/ui/screens/permission_screen.dart';
import 'package:line_ctrl_app/ui/widgets/dialogs.dart';

import '../enums/controller_type.dart';
import '../error_handling/app_error_handler.dart';

class BluetoothConnectionModel extends ChangeNotifier {
  final Guid _serviceGuid = Guid('0058545f-5f5f-5f52-4148-435245574f50');
  final Guid _rightCharGuid = Guid('0058545f-5f5f-5f52-4148-435245574f51');
  final Guid _leftCharGuid = Guid('0058545f-5f5f-5f52-4148-435245574f52');
  final Guid _steeringCharGuid = Guid('0058545f-5f5f-5f52-4148-435245574f53');
  final Guid _powerCharGuid = Guid('0058545f-5f5f-5f52-4148-435245574f54');
  final Guid _powerRxCharUuid = Guid('0058545f-5f5f-5f52-4148-435245574f55');
  final StreamController<String> _logStream =
      StreamController<String>.broadcast();

  StreamSubscription<List<ScanResult>>? _scanResultSubscription;
  StreamSubscription<BluetoothConnectionState>? _deviceSubscription;
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

  bool _connected = false;
  bool _wasConnected = false;
  bool _isNotifying = false;
  bool _isScanning = false;
  bool _timerIsRunnig = false;
  BluetoothAdapterState _state = BluetoothAdapterState.unknown;
  bool get connected => _connected;
  bool get isNotifying => _isNotifying;
  bool get isScanning => _isScanning;

  set isNotifying(bool value) {
    if (value != _isNotifying) {
      _isNotifying = value;
    }
  }

  set connected(bool value) {
    if (value != _connected) {
      _connected = value;
    }
  }

  Stream<List<int>>? get notifyStream => _powerRxChar?.lastValueStream;
  Stream<String> get log => _logStream.stream;

  void _startListeningConnectionsTimer() {
    if (_timerIsRunnig) {
      return;
    }
    _timerIsRunnig = true;
    _stateSubscription =
        FlutterBluePlus.adapterState.listen(_listenBluetoothState);
    _connectionSubscription = Stream.periodic(const Duration(seconds: 5))
        .asyncMap((_) => FlutterBluePlus.connectedDevices)
        .listen(_listenConnections);
  }

  void _listenBluetoothState(BluetoothAdapterState event) {
    _state = event;
    if (_state == BluetoothAdapterState.off) {
      AppDialogs.showBluetoothAdapterStateAlert();
    }
    notifyListeners();
  }

  Future<void> startScan() async {
    if (PermissionModel().permissionSection !=
        PermissionSection.permissionGranted) {
      final locationGranted =
          await PermissionModel().requestLocationPermission();

      if (locationGranted) {
        final bluetoothGranted =
            await PermissionModel().requestBluetoothScanPermission();

        if (bluetoothGranted) {
          _startSubscriptions();
          _startScanning();
        } else {
          _goToPermissionScreen();
        }
      } else {
        _goToPermissionScreen();
      }
    } else {
      _startSubscriptions();
      _startScanning();
    }
  }

  void _goToPermissionScreen() {
    AppDialogs.navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const PermissionScreen()),
    );
  }

  void _startScanning() {
    _scanSubscription?.cancel();
    _scanResultSubscription?.cancel();
    _scanResultSubscription = FlutterBluePlus.scanResults.listen(_onScanResult);
    _scanSubscription = FlutterBluePlus.isScanning.listen(_handleScanState);
    debugPrint('start scanning');
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
  }

  void _startSubscriptions() {
    _stateSubscription?.cancel();
    _stateSubscription =
        FlutterBluePlus.adapterState.listen(_listenBluetoothState);
    _startListeningConnectionsTimer();
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
        final Stopwatch stopwatch = Stopwatch()..start();
        await _rightChar?.write(
          utf8.encode(value.toString()),
          withoutResponse: false,
        );
        stopwatch.stop();
        final elapsedMilliseconds = stopwatch.elapsedMilliseconds;
        debugPrint('timeToSend: $elapsedMilliseconds ms');
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

  Future<void> writeSteering(Uint8List msg) async {
    await _steeringChar?.write(
      msg,
      withoutResponse: false,
    );
  }

  Future<void> _subscribeNotify() async {
    _notifyStreamSubscription?.cancel();
    final BluetoothNotificationHandler notificationHandler =
        BluetoothNotificationHandler(
      notifyChar: _powerRxChar,
      setNotify: true,
    );
    notificationHandler.startNotifications()?.listen(_handleNotifyValues);
    notifyListeners();
  }

  void _listenConnections(List<BluetoothDevice> event) {
    bool hasConnections = event.isNotEmpty;
    connected = hasConnections;
    if (hasConnections != _wasConnected) {
      _wasConnected = hasConnections;
      Future.delayed(const Duration(seconds: 1), () => _subscribeNotify());
    }
  }

  void _handleDeviceState(BluetoothConnectionState? deviceState) async {
    debugPrint('device state = ${deviceState.toString()}');
    _logStream.add('device state = ${deviceState.toString()}');
    if (deviceState != BluetoothConnectionState.connected) {
      debugPrint('disconnected');
      _logStream.add('disconnected');
      _connected = false;
      isNotifying = false;
      notifyListeners();
      try {
        debugPrint('connecting');
        _logStream.add('connecting');
        await _device?.connect();
        _handleServices(await _device?.discoverServices());
      } on Exception catch (error, stacktrace) {
        AppErrorHandler.handleFlutterError(error, stacktrace);
        debugPrint('Error: $error');
        _logStream.add('Error: $error');
      }
    } else if (deviceState == BluetoothConnectionState.connected) {
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
        if (element.device.platformName == 'LineCtrl') {
          FlutterBluePlus.stopScan();
          debugPrint('found ${element.device.platformName}');
          _logStream.add('found ${element.device.platformName}');
          _device = element.device;
          _deviceSubscription =
              _device?.connectionState.listen(_handleDeviceState);
        }
      }
    }
  }

  void _handleNotifyValues(List<int> values) {
    if (values.isNotEmpty) {
      if (!isNotifying) {
        isNotifying = true;
        notifyListeners();
      }
      _logStream.add('is notifying; $isNotifying');
      debugPrint('is notifying; $isNotifying');
      debugPrint(values.toString());
      VescStateModel().update(values);
      debugPrint('notify values: ${VescStateModel().toString()}');
    } else {
      isNotifying = false;
      notifyListeners();
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
