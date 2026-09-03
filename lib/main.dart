import 'dart:async';

import 'package:flutter/material.dart';
import 'package:line_ctrl_app/models/permission_model.dart';
import 'package:line_ctrl_app/models/sensor_model.dart';
import 'package:line_ctrl_app/models/vesc_state_model.dart';
import 'package:line_ctrl_app/ui/screens/home.dart';
import 'package:line_ctrl_app/ui/widgets/dialogs.dart';
import 'package:provider/provider.dart';

import 'error_handling/app_error_handler.dart';
import 'models/bluetooth_connection_model.dart';

void main() {
  FlutterError.onError = AppErrorHandler.handleFlutterErrorDetails;
  runZonedGuarded(
    () {
      runApp(
        const LineCtrlApp(),
      );
    },
    AppErrorHandler.handlePlatformError,
  );
}

class LineCtrlApp extends StatelessWidget {
  const LineCtrlApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SensorModel>(
          create: (_) => SensorModel(),
        ),
        ChangeNotifierProvider<PermissionModel>(
          create: (_) => PermissionModel(),
        ),
        ChangeNotifierProvider<BluetoothConnectionModel>(
          create: (_) => BluetoothConnectionModel(),
        ),
        ChangeNotifierProvider<VescStateModel>(
          create: (_) => VescStateModel(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: AppDialogs.navigatorKey,
        theme: ThemeData.dark(),
        home: const HomeScreen(),
      ),
    );
  }
}
