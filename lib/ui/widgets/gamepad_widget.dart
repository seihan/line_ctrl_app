import 'package:flutter/material.dart';
import 'package:line_ctrl_app/models/steering_model.dart';
import 'package:line_ctrl_app/ui/widgets/spring_button.dart';

class GamepadWidget extends StatelessWidget {
  final SteeringModel model;
  const GamepadWidget({Key? key, required this.model}) : super(key: key);

  static const double outerButtonsWidthScale = 0.2;
  static const double centerButtonsWidthScale = 0.45;
  static const double outerButtonsHeightScale = 0.63;
  static const double centerButtonsHeightScale = 0.3;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: screenHeight * outerButtonsHeightScale,
          width: screenWidth * outerButtonsWidthScale,
          child: SpringButton(onValueChanged: model.onLeftValueChanged),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: screenHeight * centerButtonsHeightScale,
              width: screenWidth * centerButtonsWidthScale,
              child: ElevatedButton(
                onPressed: () => model.onPowerValueChanged(1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      8.0,
                    ), // Adjust the radius as needed
                  ),
                ),
                child: const Text('Throttle'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: screenHeight * centerButtonsHeightScale,
              width: screenWidth * centerButtonsWidthScale,
              child: ElevatedButton(
                onPressed: () => model.onPowerValueChanged(-1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      8.0,
                    ), // Adjust the radius as needed
                  ),
                ),
                child: const Text('Brake'),
              ),
            ),
          ],
        ),
        SizedBox(
          height: screenHeight * outerButtonsHeightScale,
          width: screenWidth * outerButtonsWidthScale,
          child: SpringButton(onValueChanged: model.onRightValueChanged),
        ),
      ],
    );
  }
}
