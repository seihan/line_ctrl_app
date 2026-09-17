import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:line_ctrl_app/utils.dart';

class SettingsSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String title;

  const SettingsSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    this.title = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(title),
        ),
        Expanded(
          child: FlutterSlider(
            values: [value],
            min: 0,
            max: 1,
            rtl: false,
            step: const FlutterSliderStep(step: 0.01),
            centeredOrigin: false,
            trackBar: FlutterSliderTrackBar(
              activeTrackBarHeight: Utils.scale(
                value: value,
                inMin: 0,
                inMax: 1,
                outMin: 1,
                outMax: 30,
              ),
              activeTrackBar: BoxDecoration(
                color: Colors.white.withAlpha(
                  Utils.scale(
                    value: value,
                    inMin: 0,
                    inMax: 1,
                    outMin: 0,
                    outMax: 255,
                  ).toInt(),
                ),
              ),
              inactiveTrackBar: const BoxDecoration(
                color: Colors.white,
              ),
            ),
            axis: Axis.horizontal,
            handlerWidth: 30,
            handlerHeight: 60,
            handler: FlutterSliderHandler(
              decoration: const BoxDecoration(),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 2, horizontal: 13),
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
                  color: Colors.black.withValues(alpha: 0.7),
                ),
              ),
              format: (String value) {
                return value.split('.')[1];
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
          padding: const EdgeInsets.only(left: 25),
          child: Text(
            '${(value * 100).round().toStringAsFixed(0)}%',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
