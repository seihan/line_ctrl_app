import 'package:flutter/material.dart';
import 'package:line_ctrl_app/models/sensor_model.dart';
import 'package:line_ctrl_app/ui/widgets/settings_slider.dart';
import 'package:provider/provider.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorModel>(
      builder: (context, model, child) {
        return Container(
          padding: const EdgeInsets.only(bottom: 20.0),
          color: Colors.black87,
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Settings'),
              ),
              SettingsSlider(
                title: 'Left Motor Level',
                value: model.xFactorLeft,
                onChanged: model.onChangedXfactorLeft,
              ),
              SettingsSlider(
                title: 'Right Motor Level',
                value: model.xFactorRight,
                onChanged: model.onChangedXfactorRight,
              ),
              SettingsSlider(
                title: 'Brake Level',
                value: model.yFactorBrake,
                onChanged: model.onChangedYfactorBrake,
              ),
              SettingsSlider(
                title: 'Throttle Level',
                value: model.yFactorThrottle,
                onChanged: model.onChangedYfactorThrottle,
              ),
            ],
          ),
        );
      },
    );
  }
}
