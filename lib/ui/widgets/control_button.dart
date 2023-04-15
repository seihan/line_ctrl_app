import 'package:flutter/material.dart';

/// A square button with icon
class ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final VoidCallback? onPressed;

  const ControlButton({
    Key? key,
    required this.icon,
    required this.size,
    this.onPressed,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
        ),
        onPressed: onPressed,
        child: Icon(icon),
      ),
    );
  }
}
