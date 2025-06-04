import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothStateModel extends ChangeNotifier {
  BluetoothAdapterState _state = BluetoothAdapterState.unknown;

  bool get on => _state == BluetoothAdapterState.on;

  BluetoothStateModel() {
    _startListening();
  }

  StreamSubscription<BluetoothAdapterState>? _subscription;

  void _startListening() {
    _subscription?.cancel();
    _subscription = FlutterBluePlus.adapterState.listen(_listenBluetoothState);
  }

  void _listenBluetoothState(BluetoothAdapterState event) {
    _state = event;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
