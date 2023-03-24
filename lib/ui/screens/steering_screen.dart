import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/bluetooth_connection_model.dart';
import '../../models/sensor_model.dart';
import '../../models/steering_model.dart';
import '../widgets/control_buttons.dart';
import '../widgets/data_view.dart';

class SteeringScreen extends StatelessWidget {
  final BluetoothConnectionModel model;
  const SteeringScreen({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SteeringModel>(
      create: (_) => SteeringModel(connectionModel: model),
      child: Consumer<SteeringModel>(
        builder: (context, model, child) {
          return Scaffold(
            body: SafeArea(
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(30),
                    alignment: Alignment.bottomLeft,
                    child: ControlButtons(
                      title: 'left motor',
                      value: model.leftValue,
                      size: 69,
                      active: model.paused,
                      up: model.leftUp,
                      down: model.leftDown,
                      left: model.leftLeft,
                      right: model.leftRight,
                      middle: model.leftStop,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(30),
                    alignment: Alignment.bottomRight,
                    child: ControlButtons(
                      title: 'right motor',
                      value: model.rightValue,
                      size: 69,
                      active: model.paused,
                      up: model.rightUp,
                      down: model.rightDown,
                      left: model.rightLeft,
                      right: model.rightRight,
                      middle: model.rightStop,
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: model.togglePause,
              child: Icon(
                model.paused ? Icons.play_arrow : Icons.pause,
              ),
            ),
          );
        },
      ),
    );
  }
}

class SteeringDemo extends StatelessWidget {
  final BluetoothConnectionModel model;
  const SteeringDemo({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<SensorController>(
          builder: (context, model, child) {
            return DataView(
              stream: model.vector2,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => model.startScan(),
        backgroundColor: model.isScanning ? Colors.red : Colors.green,
        child: Icon(model.isScanning ? Icons.stop : Icons.search),
      ),
    );
  }
}
