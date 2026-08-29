import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math.dart';

import '../utils.dart';

class SensorModel extends ChangeNotifier {
  // limiter 0 .. 1
  double _xFactorLeft = 1;
  double _xFactorRight = 1;
  double _yFactorBrake = 1;
  double _yFactorThrottle = 1;

  double get xFactorLeft => _xFactorLeft;
  double get xFactorRight => _xFactorRight;
  double get yFactorBrake => _yFactorBrake;
  double get yFactorThrottle => _yFactorThrottle;

  set xFactorLeft(double value) {
    if (value != _xFactorLeft) {
      _xFactorLeft = value;
    }
  }

  set xFactorRight(double value) {
    if (value != _xFactorRight) {
      _xFactorRight = value;
    }
  }

  set yFactorBrake(double value) {
    if (value != _yFactorBrake) {
      _yFactorBrake = value;
    }
  }

  set yFactorThrottle(double value) {
    if (value != _yFactorThrottle) {
      _yFactorThrottle = value;
    }
  }

  double onChangedXfactorLeft(double value) {
    xFactorLeft = value;
    notifyListeners();
    return xFactorLeft;
  }

  double onChangedXfactorRight(double value) {
    xFactorRight = value;
    notifyListeners();
    return xFactorRight;
  }

  double onChangedYfactorBrake(double value) {
    yFactorBrake = value;
    notifyListeners();
    return yFactorBrake;
  }

  double onChangedYfactorThrottle(double value) {
    yFactorThrottle = value;
    notifyListeners();
    return yFactorThrottle;
  }

  Vector2 _vector2 = Vector2.zero();

  Stream<Vector2> get vector2 => accelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).transform(
        StreamTransformer.fromHandlers(
          handleData: _transformAccelerometerEvent,
        ),
      );

  Stream<Vector2> get vector2Ui => accelerometerEventStream(
        samplingPeriod: SensorInterval.uiInterval,
      ).transform(
        StreamTransformer.fromHandlers(
          handleData: _transformAccelerometerEvent,
        ),
      );

  static Vector2 _vecOf(AccelerometerEvent event) {
    return Vector2(event.x, event.y);
  }

  void _transformAccelerometerEvent(
    AccelerometerEvent event,
    EventSink<Vector2> sink,
  ) {
    _vector2 = _vecOf(event);
    _vector2.x = Utils.scale(
      value: _vector2.x,
      inMin: -10,
      inMax: 10,
      outMin: -255 * xFactorLeft,
      outMax: 255 * xFactorRight,
    );
    _vector2.y = Utils.scale(
      value: _vector2.y,
      inMin: -10,
      inMax: 10,
      outMin: -255 * yFactorBrake,
      outMax: 255 * yFactorThrottle,
    );
    sink.add(_vector2);
  }
}
