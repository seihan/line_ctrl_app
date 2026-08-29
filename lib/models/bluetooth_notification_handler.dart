import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothNotificationHandler {
  final BluetoothCharacteristic? notifyChar;
  final bool setNotify;

  BluetoothNotificationHandler({this.notifyChar, this.setNotify = false});

  Stream<List<int>>? startNotifications() {
    notifyChar?.setNotifyValue(setNotify);
    return notifyChar?.lastValueStream;
  }

  bool get isNotifying => notifyChar?.isNotifying ?? false;
}
