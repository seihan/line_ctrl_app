import 'package:flutter/material.dart';
import 'package:line_ctrl_app/enums/steering_display_mode.dart';
import 'package:line_ctrl_app/ui/widgets/accelerometer_bars.dart';
import 'package:line_ctrl_app/ui/widgets/connection_indicator.dart';
import 'package:line_ctrl_app/ui/widgets/control_slider_widget.dart';
import 'package:line_ctrl_app/ui/widgets/gamepad_widget.dart';
import 'package:line_ctrl_app/ui/widgets/notify_indicator.dart';
import 'package:line_ctrl_app/ui/widgets/overlay_switch.dart';
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
          Widget mainWidget;

          switch (model.displayMode) {
            case SteeringDisplayMode.controller:
              mainWidget = ControlSliderWidget(
                model: model,
              ); // or your Controller widget
              break;
            case SteeringDisplayMode.gamepad:
              mainWidget = GamepadWidget(
                model: model,
              );
              break;
            case SteeringDisplayMode.settings:
              mainWidget = const SettingsWidget();
              break;
          }
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
                  Positioned.fill(child: mainWidget),
                  if (model.displayMode != SteeringDisplayMode.settings)
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                        child: OverlaySwitch(model: model),
                      ),
                    ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SettingsButton(),
                        Row(
                          children: [
                            ConnectionIndicator(model: connectionModel),
                            const SizedBox(width: 8),
                            NotifyIndicator(model: connectionModel),
                          ],
                        ),
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
