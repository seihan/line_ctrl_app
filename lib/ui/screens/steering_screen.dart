import 'package:flutter/material.dart';
import 'package:line_ctrl_app/ui/widgets/accelerometer_bars.dart';
import 'package:line_ctrl_app/ui/widgets/control_slider.dart';
import 'package:line_ctrl_app/ui/widgets/notify_button.dart';
import 'package:provider/provider.dart';

import '../../models/bluetooth_connection_model.dart';
import '../../models/steering_model.dart';
import '../widgets/vesc_data_display.dart';

class SteeringScreen extends StatelessWidget {
  final BluetoothConnectionModel connectionModel;
  const SteeringScreen({Key? key, required this.connectionModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SteeringModel>(
      create: (_) => SteeringModel(connectionModel: connectionModel),
      child: Consumer<SteeringModel>(
        builder: (context, steering, child) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Stack(
                children: <Widget>[
                  const AccelerometerBars(),
                  const Align(
                    alignment: Alignment.topCenter,
                    child: VescDataDisplay(),
                  ),
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
                  if (connectionModel.connected == false)
                    Container(
                      color: Colors.black.withAlpha(80),
                      child: const Center(
                        child: Icon(
                          Icons.mobiledata_off_sharp,
                          size: 200.0,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: connectionModel.connected
                  ? steering.togglePause
                  : connectionModel.isScanning
                      ? null
                      : connectionModel.startScan,
              backgroundColor:
                  connectionModel.isScanning ? Colors.red : Colors.green,
              child: Icon(
                connectionModel.connected
                    ? steering.paused
                        ? Icons.play_arrow
                        : Icons.pause
                    : connectionModel.isScanning
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
