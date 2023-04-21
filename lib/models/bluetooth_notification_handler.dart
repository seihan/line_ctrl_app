import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothNotificationHandler {
  final BluetoothCharacteristic? powerRxChar;
  final bool setNotify;

  BluetoothNotificationHandler({this.powerRxChar, this.setNotify = false});

  Stream<List<int>>? startNotifications() {
    powerRxChar?.setNotifyValue(setNotify);
    return powerRxChar?.value;
  }

  bool get isNotifying => powerRxChar?.isNotifying ?? false;
}

class BluetoothWriteHandler {
  final BluetoothCharacteristic? characteristic;

  BluetoothWriteHandler({this.characteristic});
}
