import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

class ControlSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<bool>? onPressed;
  final bool active;
  final String title;

  const ControlSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    this.onPressed,
    this.active = false,
    this.title = 'no title',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Text(
            value.round().toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, color: Colors.white),
          ),
        ),
        Expanded(
          child: FlutterSlider(
            values: [value],
            max: 255,
            min: -255,
            rtl: true,
            step: const FlutterSliderStep(step: 1),
            centeredOrigin: true,
            trackBar: FlutterSliderTrackBar(
              activeTrackBarHeight: 30,
              centralWidget: const Icon(
                Icons.remove,
                color: Colors.white,
              ),
              activeTrackBar:
                  BoxDecoration(color: value < 0 ? Colors.red : Colors.green),
              inactiveTrackBar: BoxDecoration(
                color: active ? Colors.white : Colors.grey,
              ),
            ),
            axis: Axis.vertical,
            handlerWidth: 60,
            handler: FlutterSliderHandler(
              decoration: const BoxDecoration(),
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: active ? Colors.white : Colors.grey,
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 13, horizontal: 2),
                child: Container(
                  color: Colors.black,
                ),
              ),
            ),
            tooltip: FlutterSliderTooltip(
              disabled: true,
              textStyle: const TextStyle(fontSize: 17, color: Colors.white),
              boxStyle: FlutterSliderTooltipBox(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
              format: (String value) {
                return value.split('.')[0];
              },
            ),
            onDragging: (handlerIndex, lowerValue, upperValue) {
              if (value != lowerValue) {
                debugPrint(
                  'handlerIndex: $handlerIndex, lowerValue: $lowerValue, upperValue: $upperValue, value: $value',
                );
                onChanged(lowerValue);
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            title,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Switch(
            value: active,
            onChanged: onPressed,
            activeColor: Colors.white,
            activeTrackColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
