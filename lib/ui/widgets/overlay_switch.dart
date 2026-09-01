import 'package:flutter/material.dart';
import 'package:line_ctrl_app/models/steering_model.dart';

class OverlaySwitch extends StatelessWidget {
  final SteeringModel model;
  const OverlaySwitch({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(model.showGamepad ? 'Slider' : 'Gamepad'),
        const SizedBox(height: 10),
        Switch(
          onChanged: model.onOverlaySwitchChanged,
          value: model.showGamepad,
        ),
      ],
    );
  }
}
