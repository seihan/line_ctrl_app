import 'package:flutter/material.dart';
import 'package:line_ctrl_app/models/steering_model.dart';
import 'package:line_ctrl_app/ui/widgets/pushable_button.dart';

class GamepadWidget extends StatelessWidget {
  final SteeringModel model;
  const GamepadWidget({Key? key, required this.model}) : super(key: key);

  static const double outerButtonsWidthScale = 0.2;
  static const double outerPushButtonHeightScale = 0.60;
  static const double centerButtonsWidthScale = 0.45;
  static const double outerButtonsHeightScale = 0.63;
  static const double centerButtonsHeightScale = 0.3;
  static const double centerPushButtonsHeightScale = 0.27;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // left button
          SizedBox(
            height: screenHeight * outerButtonsHeightScale,
            width: screenWidth * outerButtonsWidthScale,
            child: PushableButton(
              height: screenHeight * outerPushButtonHeightScale,
              onPressed: () => model.onLeftValueChanged(1),
              onReleased: () => model.onLeftValueChanged(0),
              hslColor: const HSLColor.fromAHSL(1.0, 356, 1.0, 0.43),
              child: const Text('Left'),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // top center - throttle
              SizedBox(
                height: screenHeight * centerButtonsHeightScale,
                width: screenWidth * centerButtonsWidthScale,
                child: PushableButton(
                  height: screenHeight * centerPushButtonsHeightScale,
                  onPressed: () => model.onPowerValueChanged(1),
                  onReleased: () => model.onPowerValueChanged(0),
                  hslColor: const HSLColor.fromAHSL(1.0, 256, 1.0, 0.43),
                  child: const Text('Throttle'),
                ),
              ),
              const SizedBox(height: 20),
              // bottom center - brake
              SizedBox(
                height: screenHeight * centerButtonsHeightScale,
                width: screenWidth * centerButtonsWidthScale,
                child: PushableButton(
                  height: screenHeight * centerPushButtonsHeightScale,
                  onPressed: () => model.onPowerValueChanged(-1),
                  onReleased: () => model.onPowerValueChanged(0),
                  hslColor: const HSLColor.fromAHSL(1.0, 156, 1.0, 0.43),
                  child: const Text('Brake'),
                ),
              ),
            ],
          ),
          // right
          SizedBox(
            height: screenHeight * outerButtonsHeightScale,
            width: screenWidth * outerButtonsWidthScale,
            child: PushableButton(
              height: screenHeight * 0.60,
              onPressed: () => model.onRightValueChanged(1),
              onReleased: () => model.onRightValueChanged(0),
              hslColor: const HSLColor.fromAHSL(1.0, 56, 1.0, 0.43),
              child: const Text('Right'),
            ),
          ),
        ],
      ),
    );
  }
}
