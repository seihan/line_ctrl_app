import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_ctrl_app/models/bluetooth_connection_model.dart';
import 'package:line_ctrl_app/ui/screens/steering_screen.dart';
import 'package:provider/provider.dart';

import '../widgets/connection_log_viewer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    return ChangeNotifierProvider<BluetoothConnectionModel>(
      create: (_) => BluetoothConnectionModel()..initialize(),
      child: Consumer<BluetoothConnectionModel>(
        builder: (context, connectionModel, child) {
          return Stack(
            children: [
              ConnectionLogViewer(
                model: connectionModel,
              ),
              SteeringScreen(
                model: connectionModel,
              ),
            ],
          );
        },
      ),
    );
  }
}
