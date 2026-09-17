import 'package:flutter/material.dart';
import 'package:line_ctrl_app/models/settings_model.dart';
import 'package:line_ctrl_app/ui/widgets/settings_slider.dart';
import 'package:provider/provider.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(
      builder: (context, model, child) {
        return Container(
          padding: const EdgeInsets.only(bottom: 20.0),
          color: Colors.black,
          child: ListView(
            children: [
              const Text('Settings'),
              SettingsSlider(
                title: 'Brake',
                value: model.factorBrake,
                onChanged: model.onChangedFactorBrake,
              ),
              SettingsSlider(
                title: 'Throttle',
                value: model.factorThrottle,
                onChanged: model.onChangedFactorThrottle,
              ),
              SettingsSlider(
                title: 'Left',
                value: model.factorLeft,
                onChanged: model.onChangedFactorLeft,
              ),
              SettingsSlider(
                title: 'Right',
                value: model.factorRight,
                onChanged: model.onChangedFactorRight,
              ),
            ],
          ),
        );
      },
    );
  }
}
