import 'package:flutter/material.dart';

class ControlSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<bool>? onPressed;
  final bool active;
  final String title;

  const ControlSlider(
      {Key? key,
      required this.value,
      required this.onChanged,
      this.onPressed,
      this.active = false,
      this.title = 'no title'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Text(
            value.toString(),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: Slider(
              min: -255,
              max: 255,
              value: value,
              secondaryTrackValue: 0,
              inactiveColor: Colors.white24,
              secondaryActiveColor: Colors.red,
              activeColor: value == 0
                  ? Colors.grey
                  : value < 0
                      ? Colors.white24
                      : Colors.green,
              thumbColor: value == 0
                  ? Colors.grey
                  : value < 0
                      ? Colors.red
                      : Colors.green,
              label: value.round().toString(),
              onChanged: onChanged,
            ),
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
