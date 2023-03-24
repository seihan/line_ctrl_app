import 'dart:async';

import 'package:flutter/material.dart';
import 'package:line_ctrl_app/models/permission_model.dart';
import 'package:line_ctrl_app/models/sensor_model.dart';
import 'package:line_ctrl_app/ui/screens/bluetooth_off_screen.dart';
import 'package:line_ctrl_app/ui/screens/home.dart';
import 'package:line_ctrl_app/ui/screens/permission_screen.dart';
import 'package:provider/provider.dart';

import 'error_handling/custom_error_handler.dart';
import 'models/bluetooth_state_model.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    // Handle the Flutter error and stack trace
    CustomErrorHandler.handleFlutterError(
      details.exception,
      details.stack,
    );
  };
  runZonedGuarded(() {
    runApp(const LineCtrlApp());
  }, (error, stackTrace) {
    // Handle the platform error and stack trace
    CustomErrorHandler.handlePlatformError(error, stackTrace);
  });
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
        ChangeNotifierProvider(
          create: (_) => PermissionModel()..requestLocationPermission(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: Consumer2<BluetoothStateModel, PermissionModel>(
          builder: (context, bluetoothState, permissionModel, child) {
            return bluetoothState.on
                ? permissionModel.permissionSection ==
                        PermissionSection.permissionGranted
                    ? const HomeScreen()
                    : const PermissionScreen()
                : const BluetoothOffScreen();
          },
        ),
      ),
    );
  }
}
