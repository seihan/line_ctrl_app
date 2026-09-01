import 'package:flutter/material.dart';
import 'package:line_ctrl_app/models/steering_model.dart';

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
        Container(
          height: screenHeight * outerButtonsHeightScale,
          width: screenWidth * outerButtonsWidthScale,
          color: Colors.grey,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: screenHeight * centerButtonsHeightScale,
              width: screenWidth * centerButtonsWidthScale,
              color: Colors.green,
            ),
            const SizedBox(height: 10),
            Container(
              height: screenHeight * centerButtonsHeightScale,
              width: screenWidth * centerButtonsWidthScale,
              color: Colors.blue,
            ),
          ],
        ),
        Container(
          height: screenHeight * outerButtonsHeightScale,
          width: screenWidth * outerButtonsWidthScale,
          color: Colors.grey,
        ),
      ],
    );
  }
}
