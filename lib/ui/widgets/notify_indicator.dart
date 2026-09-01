import 'package:flutter/material.dart';
import 'package:line_ctrl_app/models/bluetooth_connection_model.dart';

class NotifyIndicator extends StatelessWidget {
  final BluetoothConnectionModel model;
  const NotifyIndicator({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.podcasts,
      color: model.isNotifying ? Colors.blue : Colors.grey,
    );
  }
}
