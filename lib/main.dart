import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:line_ctrl_app/ui/bluetooth_off_screen.dart';
import 'package:line_ctrl_app/ui/permission_screen.dart';

void main() {
  runApp(const LineCtrlApp());
}

class LineCtrlApp extends StatelessWidget {
  const LineCtrlApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: StreamBuilder<BluetoothState>(
        stream: FlutterBluePlus.instance.state,
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            return const PermissionScreen();
          }
          return BluetoothOffScreen(state: state);
        },
      ),
    );
  }
}
