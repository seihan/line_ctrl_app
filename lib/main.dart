import 'package:flutter/material.dart';
import 'package:line_ctrl_app/models/sensor_model.dart';
import 'package:line_ctrl_app/ui/bluetooth_off_screen.dart';
import 'package:line_ctrl_app/ui/permission_screen.dart';
import 'package:provider/provider.dart';

import 'models/bluetooth_state_model.dart';

void main() {
  runApp(const LineCtrlApp());
}

class LineCtrlApp extends StatelessWidget {
  const LineCtrlApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BluetoothStateModel>(
          create: (_) => BluetoothStateModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => SensorController(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: Consumer<BluetoothStateModel>(
          builder: (context, model, child) {
            return model.on
                ? const PermissionScreen()
                : const BluetoothOffScreen();
          },
        ),
      ),
    );
  }
}
