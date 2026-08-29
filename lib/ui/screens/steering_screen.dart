import 'package:flutter/material.dart';
import 'package:line_ctrl_app/ui/widgets/accelerometer_bars.dart';
import 'package:line_ctrl_app/ui/widgets/control_slider.dart';
import 'package:line_ctrl_app/ui/widgets/notify_button.dart';
import 'package:line_ctrl_app/ui/widgets/settings_button.dart';
import 'package:line_ctrl_app/ui/widgets/settings_widget.dart';
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
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: Colors.black, //Colors.transparent,
            body: SafeArea(
              child: Stack(
                children: <Widget>[
                  const AccelerometerBars(),
                  const Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 44),
                      child: VescDataDisplay(),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 20,
                      ),
                      child: Icon(
                        connectionModel.connected
                            ? Icons.sensors_sharp
                            : Icons.sensors_off,
                        color: connectionModel.connected
                            ? Colors.blue
                            : Colors.white54,
                      ),
                    ),
                  ),
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
                  if (model.showSettings) const SettingsWidget(),
                  const Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SettingsButton(),
                        NotifyButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: connectionModel.connected
                  ? model.togglePause
                  : connectionModel.isScanning
                      ? null
                      : connectionModel.startScan,
              backgroundColor:
                  connectionModel.isScanning ? Colors.red : Colors.green,
              child: Icon(
                connectionModel.connected
                    ? model.paused
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
