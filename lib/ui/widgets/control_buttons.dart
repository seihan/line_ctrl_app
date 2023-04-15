import 'package:flutter/material.dart';

import 'control_button.dart';

class ControlButtons extends StatelessWidget {
  final String? title;
  final double? size;
  final bool? active;
  final int? value;
  final Color? color;
  final VoidCallback? up;
  final VoidCallback? down;
  final VoidCallback? left;
  final VoidCallback? right;
  final VoidCallback? middle;

  final double _defaultSize = 40;

  const ControlButtons({
    Key? key,
    this.title,
    this.size,
    this.active,
    this.value,
    this.up,
    this.down,
    this.left,
    this.right,
    this.middle,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('$title = $value'),
          ControlButton(
            color: color,
            icon: Icons.arrow_upward,
            size: size ?? _defaultSize,
            onPressed: (active ?? false) ? up : null,
          ),
          Row(
            children: [
              ControlButton(
                color: color,
                icon: Icons.arrow_back,
                size: size ?? _defaultSize,
                onPressed: (active ?? false) ? left : null,
              ),
              const Spacer(),
              ControlButton(
                color: color,
                icon: Icons.stop,
                size: size ?? _defaultSize,
                onPressed: (active ?? false) ? middle : null,
              ),
              const Spacer(),
              ControlButton(
                color: color,
                icon: Icons.arrow_forward,
                size: size ?? _defaultSize,
                onPressed: (active ?? false) ? right : null,
              )
            ],
          ),
          ControlButton(
            color: color,
            icon: Icons.arrow_downward,
            size: size ?? _defaultSize,
            onPressed: (active ?? false) ? down : null,
          ),
        ],
      ),
    );
  }
}
