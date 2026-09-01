import 'package:flutter/material.dart';
import 'package:line_ctrl_app/models/steering_model.dart';
import 'package:line_ctrl_app/ui/widgets/control_slider.dart';

class ControlSliderWidget extends StatelessWidget {
  final SteeringModel model;
  const ControlSliderWidget({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
