import 'package:flutter/material.dart';

class SpringButton extends StatefulWidget {
  final ValueChanged<double>? onValueChanged;
  const SpringButton({Key? key, this.onValueChanged}) : super(key: key);

  @override
  State<SpringButton> createState() => _SpringButtonState();
}

class _SpringButtonState extends State<SpringButton>
    with SingleTickerProviderStateMixin {
  double value = 0.0; // current value between 0 and 1
  late AnimationController _springController;
  late Animation<double> _springAnimation;

  // Variables to track gesture
  double _initialY = 0.0;
  // ignore: unused_field
  bool _isIncreasing = false;
  bool _isFixed = false;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _springAnimation = CurvedAnimation(
      parent: _springController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _setValue(double val) {
    setState(() {
      value = val;
    });
  }

  void _animateToZero() {
    _springController.reset();
    _springAnimation = Tween<double>(begin: value, end: 0.0).animate(
      CurvedAnimation(
        parent: _springController,
        curve: Curves.elasticOut,
      ),
    )..addListener(() => _setValue(_springAnimation.value));
    _springController.forward();

    // Call the callback with the updated value
    if (widget.onValueChanged != null) {
      widget.onValueChanged!(value);
    }
  }

  void _increaseValue() {
    _setValue((value + 0.01).clamp(0.0, 1.0));
  }

  void _decreaseValue() {
    _setValue((value - 0.01).clamp(0.0, 1.0));
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isFixed) {
      return;
    }
    double deltaY = _initialY - details.localPosition.dy;
    // If swiping up
    if (deltaY > 0) {
      _isIncreasing = true;
      _increaseValue();
    } else if (deltaY < 0) {
      _isIncreasing = false;
      _decreaseValue();
    }
    _initialY = details.localPosition.dy;

    // Call the callback with the updated value
    if (widget.onValueChanged != null) {
      widget.onValueChanged!(value);
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (_isFixed) {
      _setValue(1);
      if (widget.onValueChanged != null) {
        widget.onValueChanged!(1);
      }
    } else {
      _animateToZero();
    }
  }

  void _onDoubleTap() {
    setState(() {
      _isFixed = !_isFixed;
    });
    if (_isFixed) {
      _setValue(1);
      _springController.stop();
    } else {
      _animateToZero();
    }
    if (widget.onValueChanged != null) {
      widget.onValueChanged!(_isFixed ? 1 : 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: _isFixed ? 4.0 : 0.0, // Elevation when fixed
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        // Only splash when fixed
        splashColor:
            _isFixed ? Colors.blue.withValues(alpha: 0.3) : Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        onTapDown: _onTapDown,
        onDoubleTap: _onDoubleTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // The handle
              Positioned(
                bottom: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (details) {
                    _initialY = details.localPosition.dy;
                  },
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: (_) {
                    // Animate back to zero
                    _animateToZero();
                  },
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: Icon(
                      _isFixed ? Icons.lock : Icons.drag_handle,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                child: Text(
                  '${(value * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              // Optional: display current value as a filled rectangle
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: value,
                    widthFactor: 1,
                    child: Container(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
