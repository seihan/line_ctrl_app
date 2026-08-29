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
                title: 'Brake Level',
                value: model.xFactorBrake,
                onChanged: model.onChangedXfactorBrake,
              ),
              SettingsSlider(
                title: 'Throttle Level',
                value: model.xFactorThrottle,
                onChanged: model.onChangedXfactorThrottle,
              ),
              SettingsSlider(
                title: 'Motor Forward Level',
                value: model.yFactorLeft,
                onChanged: model.onChangedYfactorLeft,
              ),
              SettingsSlider(
                title: 'Motor Backward Level',
                value: model.yFactorRight,
                onChanged: model.onChangedYfactorRight,
              ),
            ],
          ),
        );
      },
    );
  }
}
