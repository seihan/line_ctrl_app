import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:line_ctrl_app/ui/screens/bluetooth_screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _subscriptions = <StreamSubscription>[];
  final _scanResult = FlutterBlue.instance.scanResults;
  final _connectedDevices = Stream.periodic(const Duration(seconds: 2))
      .asyncMap((_) => FlutterBlue.instance.connectedDevices);
  late BluetoothDeviceState state = BluetoothDeviceState.disconnected;
  late BluetoothDevice device;
  late BluetoothService lineService;
  late BluetoothCharacteristic rightChar;
  late BluetoothCharacteristic leftChar;
  late BluetoothCharacteristic powerChar;
  final Guid serviceGuid = Guid("3a39152a-6371-4730-8e24-31be298cf059");
  final Guid rightCharGuid = Guid("74454618-2b9a-4c9a-bc20-b351dc7bd269");
  final Guid leftCharGuid = Guid("bf3e592d-063b-4b25-884e-5814640054e9");
  final Guid powerCharGuid = Guid("6cc05bc7-d9da-4b6e-9bfa-65e6c0b5b9d3");
  late bool subscribed = false;

  @override
  void initState() {
    _findLineCtrlServer();
    super.initState();
  }

  @override
  void dispose() {
    for (var element in _subscriptions) {
      element.cancel();
    }
    super.dispose();
  }

  void _findLineCtrlServer() {
    //start scanning
    FlutterBlue.instance.startScan(timeout: const Duration(seconds: 4));
    //listen on results
    _subscriptions.add(_scanResult.listen(_handleScanResult));
    //listen on connected device to watch the state
    _subscriptions.add(_connectedDevices.listen(_handleDevices));
  }

  void _handleDeviceState(BluetoothDeviceState deviceState) {
    state = deviceState;
    if (deviceState == BluetoothDeviceState.connected &&
        _subscriptions.length < 4) {
      _subscriptions.add(device.services.listen(_handleServices));
    }
  }

  void _handleDevices(List<BluetoothDevice> devices) {
    print(_subscriptions.length);
    if (devices.isNotEmpty && _subscriptions.length < 3) {
      _subscriptions.add(device.state.listen(_handleDeviceState));
    }
  }

  void _handleScanResult(List<ScanResult> results) {
    if (results.isNotEmpty) {
      if (results.first.device.name == "Line Ctrl" &&
          state != BluetoothDeviceState.connecting &&
          state != BluetoothDeviceState.connected) {
        print("Found " + results.first.device.name);
        device = results.first.device;
        print("connecting...");
        device.connect();
        state = BluetoothDeviceState.connecting;
      }
    }
  }

  void _handleServices(List<BluetoothService> services) {
    bool r = false;
    bool l = false;
    bool p = false;
    if (state == BluetoothDeviceState.connected) {
      device.discoverServices();
      if (services.isNotEmpty) {
        print(services.first.uuid);
        for (var element in services) {
          if (element.uuid == serviceGuid) {
            print("found line ctrl service");
            lineService = element;
            for (var element in lineService.characteristics) {
              if (element.uuid == rightCharGuid) {
                print("found right char");
                rightChar = element;
                r = true;
              }
              if (element.uuid == leftCharGuid) {
                print("found left char");
                leftChar = element;
                l = true;
                //              leftChar.write(utf8.encode("-255"));
              }
              if (element.uuid == powerCharGuid) {
                print("found power char");
                powerChar = element;
                p = true;
//                powerChar.write(utf8.encode("200"));
              }
            }
            if (r && l && p) {
              for (var element in _subscriptions) {
                element.cancel();
              }
              setState(() {
                subscribed = true;
              });
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          child: const Text("push"),
          onPressed: () async =>
              subscribed ? await powerChar.write(utf8.encode("255")) : null,
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              child: const Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: const Icon(Icons.search),
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: const Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}
