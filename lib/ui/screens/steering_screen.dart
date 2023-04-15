import 'package:flutter/material.dart';
import 'package:line_ctrl_app/ui/widgets/accelerometer_bars.dart';
import 'package:line_ctrl_app/ui/widgets/notify_button.dart';
import 'package:provider/provider.dart';

import '../../models/bluetooth_connection_model.dart';
import '../../models/steering_model.dart';
import '../widgets/control_buttons.dart';

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
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Stack(
                children: <Widget>[
                  const AccelerometerBars(),
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
                  Container(
                    padding: const EdgeInsets.all(30),
                    alignment: Alignment.bottomCenter,
                    child: ControlButtons(
                      title: 'power motor',
                      value: model.powerValue,
                      size: 69,
                      color: Colors.red,
                      active: model.paused,
                      up: model.powerUp,
                      down: model.powerDown,
                      left: model.powerForward,
                      right: model.powerBackward,
                      middle: model.powerStop,
                    ),
                  ),
                  const Align(
                    alignment: Alignment.topRight,
                    child: NotifyButton(),
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
