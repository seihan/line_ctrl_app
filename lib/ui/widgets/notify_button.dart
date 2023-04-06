import 'package:flutter/material.dart';
import 'package:line_ctrl_app/models/bluetooth_connection_model.dart';
import 'package:provider/provider.dart';

class NotifyButton extends StatelessWidget {
  const NotifyButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothConnectionModel>(
      builder: (context, model, child) {
        return IconButton(
          onPressed: model.toggleNotify,
          icon: const Icon(
            Icons.podcasts,
          ),
          color: model.isNotifying ? Colors.blue : Colors.grey,
        );
      },
    );
  }
}
