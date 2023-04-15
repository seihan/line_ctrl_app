import 'package:flutter/material.dart';
import 'package:line_ctrl_app/ui/widgets/accelerometer_bars.dart';
import 'package:line_ctrl_app/ui/widgets/control_slider.dart';
import 'package:line_ctrl_app/ui/widgets/notify_button.dart';
import 'package:provider/provider.dart';

import '../../models/bluetooth_connection_model.dart';
import '../../models/steering_model.dart';

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ControlSlider(
                        title: 'Left',
                        value: model.leftValue.toDouble(),
                        active: model.activeLeft,
                        onChanged: model.onChangedLeft,
                        onPressed: model.toggleLeft,
                      ),
                      ControlSlider(
                        title: 'Power',
                        value: model.powerValue.toDouble(),
                        active: model.activePower,
                        onChanged: model.onChangedPower,
                        onPressed: model.togglePower,
                      ),
                      ControlSlider(
                        title: 'Right',
                        value: model.rightValue.toDouble(),
                        active: model.activeRight,
                        onChanged: model.onChangedRight,
                        onPressed: model.toggleRight,
                      ),
                    ],
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
