import 'package:flutter/material.dart';
import 'package:line_ctrl_app/models/steering_model.dart';
import 'package:provider/provider.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SteeringModel>(
      builder: (context, model, child) {
        return IconButton(
          onPressed: model.onPressedSettingsButton,
          icon: const Icon(
            Icons.settings,
          ),
          color: model.showSettings ? Colors.blue : Colors.grey,
        );
      },
    );
  }
}
