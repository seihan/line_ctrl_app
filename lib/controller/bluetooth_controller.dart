import 'dart:async';
import 'dart:convert';
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

  final Stream _connectedDevices =
      Stream.periodic(const Duration(seconds: 2))
          .asyncMap((_) => FlutterBlue.instance.connectedDevices);

  Stream<bool> get connected => _connectedDevices.transform(
      StreamTransformer.fromHandlers(handleData: _handleConnectedDevices));

  void startScan() {
    print("start scanning");
    FlutterBlue.instance.startScan(timeout: const Duration(seconds: 5));
  }

  void init() {
    _streamSubscriptions
        .add(FlutterBlue.instance.scanResults.listen(_handleScanResult));
  }

  void write({int value = 0, required ControllerType type}) {
    switch (type) {
      case ControllerType.left:
        _leftChar.write(utf8.encode(value.toString()), withoutResponse: true);
        break;
      case ControllerType.power:
        _powerChar.write(utf8.encode(value.toString()), withoutResponse: true);
        break;
      case ControllerType.right:
        _rightChar.write(utf8.encode(value.toString()), withoutResponse: true);
        break;
    }
  }

  void _handleDeviceState(BluetoothDeviceState deviceState) async {
    if (deviceState != BluetoothDeviceState.connecting ||
        deviceState != BluetoothDeviceState.connected ||
        deviceState == BluetoothDeviceState.disconnected) {
      try {
        print("connecting");
        await _device.connect();
      } catch (e) {
        print(e);
      } finally {
        _handleServices(await _device.discoverServices());
      }
    } else {
      print("disconnected");
    }
  }

  void _handleServices(List<BluetoothService> services) {
    if (services.isNotEmpty) {
      print(services.first.uuid);
      for (var element in services) {
        if (element.uuid == _serviceGuid) {
          print("found line ctrl service");
          _lineService = element;
          for (var element in _lineService.characteristics) {
            if (element.uuid == _leftCharGuid) {
              print("found left char");
              _leftChar = element;
            }
            if (element.uuid == _powerCharGuid) {
              print("found power char");
              _powerChar = element;
            }
            if (element.uuid == _rightCharGuid) {
              print("found right char");
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
          print("found " + element.device.name);
          _device = element.device;
          if (_streamSubscriptions.length < 4) {
            _streamSubscriptions.add(_device.state.listen(_handleDeviceState));
          }
        }
      }
    }
  }

  void _handleConnectedDevices(devices, EventSink<bool> sink) {
    if (devices.isNotEmpty) {
      _connected = true;
    } else {
      _connected = false;
    }
    sink.add(_connected);
  }

  void dispose() {
    for (var element in _streamSubscriptions) {
      element.cancel();
    }
    _device.disconnect();
  }
}
