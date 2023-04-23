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
        builder: (context, steering, child) {
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
                        value: steering.leftValue.toDouble(),
                        active: steering.activeLeft,
                        onChanged: steering.onChangedLeft,
                        onPressed: steering.toggleLeft,
                      ),
                      ControlSlider(
                        title: 'Power',
                        value: steering.powerValue.toDouble(),
                        active: steering.activePower,
                        onChanged: steering.onChangedPower,
                        onPressed: steering.togglePower,
                      ),
                      ControlSlider(
                        title: 'Right',
                        value: steering.rightValue.toDouble(),
                        active: steering.activeRight,
                        onChanged: steering.onChangedRight,
                        onPressed: steering.toggleRight,
                      ),
                    ],
                  ),
                  const Align(
                    alignment: Alignment.topRight,
                    child: NotifyButton(),
                  ),
                  if (model.connected == false)
                    Container(
                      color: Colors.black.withAlpha(80),
                      child: const Center(
                        child: Icon(
                          Icons.no_drinks_sharp,
                          size: 200.0,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: model.connected
                  ? steering.togglePause
                  : model.isScanning
                      ? null
                      : model.startScan,
              backgroundColor: model.isScanning ? Colors.red : Colors.green,
              child: Icon(
                model.connected
                    ? steering.paused
                        ? Icons.play_arrow
                        : Icons.pause
                    : model.isScanning
                        ? Icons.stop
                        : Icons.search,
              ),
            ),
          );
        },
      ),
    );
  }
}
