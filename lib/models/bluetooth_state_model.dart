import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothStateModel extends ChangeNotifier {
  BluetoothState _state = BluetoothState.unknown;

  bool get on => _state == BluetoothState.on;

  BluetoothStateModel() {
    _startListening();
  }

  StreamSubscription<BluetoothState>? _subscription;

  void _startListening() {
    _subscription?.cancel();
    _subscription =
        FlutterBluePlus.instance.state.listen(_listenBluetoothState);
  }

  void _listenBluetoothState(BluetoothState event) {
    _state = event;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
