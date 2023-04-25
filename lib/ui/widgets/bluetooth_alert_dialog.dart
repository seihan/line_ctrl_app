import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothAlertDialog extends StatelessWidget {
  const BluetoothAlertDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bluetooth Adapter is not available.'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await FlutterBluePlus.instance.turnOn();
          },
          child: const Text('Turn On'),
        ),
      ],
    );
  }
}
