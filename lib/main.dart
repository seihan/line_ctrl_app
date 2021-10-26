import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:line_ctrl_app/ui/screens/bluetooth_off_screen.dart';
import 'package:line_ctrl_app/ui/screens/home.dart';

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
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return const HomeScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}
