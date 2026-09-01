import 'package:flutter/material.dart';
import 'package:line_ctrl_app/models/bluetooth_connection_model.dart';

class ConnectionIndicator extends StatelessWidget {
  final BluetoothConnectionModel model;
  const ConnectionIndicator({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      model.connected ? Icons.sensors_sharp : Icons.sensors_off,
      color: model.connected ? Colors.blue : Colors.white54,
    );
  }
}
