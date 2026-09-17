import 'package:flutter/material.dart';

import 'package:line_ctrl_app/models/animation_controller_state.dart';

/// A widget to show a "3D" pushable button
class PushableButton extends StatefulWidget {
  const PushableButton({
    Key? key,
    this.child,
    required this.hslColor,
    required this.height,
    this.elevation = 8.0,
    this.onPressed,
    this.onReleased,
  })  : assert(height > 0),
        super(key: key);

  /// child widget (normally a Text or Icon)
  final Widget? child;

  /// Color of the top layer
  /// The color of the bottom layer is derived by decreasing the luminosity by 0.15
  final HSLColor hslColor;

  /// height of the top layer
  final double height;

  /// elevation or "gap" between the top and bottom layer
  final double elevation;

  /// button pressed callback
  final VoidCallback? onPressed;

  /// button released callback
  final VoidCallback? onReleased;

  @override
  State<PushableButton> createState() => _PushableButtonState();
}

class _PushableButtonState extends AnimationControllerState<PushableButton> {
  _PushableButtonState() : super(const Duration(milliseconds: 100));

  bool _isDragInProgress = false;
  Offset _gestureLocation = Offset.zero;

  void _handleTapDown(TapDownDetails details) {
    _gestureLocation = details.localPosition;
    animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    animationController.reverse();
  }

  void _handleTapCancel() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_isDragInProgress && mounted) {
        animationController.reverse();
      }
    });
  }

  void _handleDragStart(DragStartDetails details) {
    _gestureLocation = details.localPosition;
    _isDragInProgress = true;
    animationController.forward();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _gestureLocation = details.localPosition;
  }

  void _handleDragEnd(Size buttonSize) {
    if (_isDragInProgress) {
      _isDragInProgress = false;
      animationController.reverse();
    }
    if (_gestureLocation.dx >= 0 &&
        _gestureLocation.dy < buttonSize.width &&
        _gestureLocation.dy >= 0 &&
        _gestureLocation.dy < buttonSize.height) {}
  }

  void _handleDragCancel() {
    if (_isDragInProgress) {
      _isDragInProgress = false;
      animationController.reverse();
    }
  }

  // Internal methods to handle pointer events
  void _handlePointerDown() {
    widget.onPressed?.call();
  }

  void _handlePointerUp() {
    widget.onReleased?.call();
  }

  @override
  Widget build(BuildContext context) {
    final totalHeight = widget.height + widget.elevation;
    return SizedBox(
      height: totalHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttonSize = Size(constraints.maxWidth, constraints.maxHeight);
          return Listener(
            onPointerDown: (PointerDownEvent event) {
              // When pointer touches down
              _handlePointerDown();
            },
            onPointerUp: (PointerUpEvent event) {
              // When pointer is released
              _handlePointerUp();
            },
            child: GestureDetector(
              // Keep your existing gesture detection if needed
              // or remove gesture callbacks if all handling is via Listener
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onHorizontalDragStart: _handleDragStart,
              onHorizontalDragEnd: (_) => _handleDragEnd(buttonSize),
              onHorizontalDragCancel: _handleDragCancel,
              onHorizontalDragUpdate: _handleDragUpdate,
              onVerticalDragStart: _handleDragStart,
              onVerticalDragEnd: (_) => _handleDragEnd(buttonSize),
              onVerticalDragCancel: _handleDragCancel,
              onVerticalDragUpdate: _handleDragUpdate,
              child: AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  final top = animationController.value * widget.elevation;
                  final hslColor = widget.hslColor;
                  final bottomHslColor = hslColor.withLightness(
                    hslColor.lightness - 0.15,
                  );
                  return Stack(
                    children: [
                      // Bottom layer
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: totalHeight - top,
                          decoration: BoxDecoration(
                            color: bottomHslColor.toColor(),
                            borderRadius: BorderRadius.circular(
                              16,
                            ), // Adjust radius as needed
                          ),
                        ),
                      ),
                      // Top layer
                      Positioned(
                        left: 0,
                        right: 0,
                        top: top,
                        child: Container(
                          height: widget.height,
                          decoration: BoxDecoration(
                            color: hslColor.toColor(),
                            borderRadius: BorderRadius.circular(
                              16,
                            ), // Same radius here for consistency
                          ),
                          child: Center(child: widget.child),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
