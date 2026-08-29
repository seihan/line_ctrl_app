import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math.dart';

import '../utils.dart';

class SensorModel extends ChangeNotifier {
  static final SensorModel _instance = SensorModel._internal();
  factory SensorModel() {
    return _instance;
  }
// constructor
  SensorModel._internal();

  // limiter 0 .. 1
  double _xFactorBrake = 1;
  double _xFactorThrottle = 1;
  double _yFactorLeft = 1;
  double _yFactorRight = 1;

  double get xFactorBrake => _xFactorBrake;
  double get xFactorThrottle => _xFactorThrottle;
  double get yFactorLeft => _yFactorLeft;
  double get yFactorRight => _yFactorRight;

  set xFactorBrake(double value) {
    if (value != _xFactorBrake) {
      _xFactorBrake = value;
      notifyListeners();
    }
  }

  set xFactorThrottle(double value) {
    if (value != _xFactorThrottle) {
      _xFactorThrottle = value;
      notifyListeners();
    }
  }

  set yFactorLeft(double value) {
    if (value != _yFactorLeft) {
      _yFactorLeft = value;
      notifyListeners();
    }
  }

  set yFactorRight(double value) {
    if (value != _yFactorRight) {
      _yFactorRight = value;
      notifyListeners();
    }
  }

  double onChangedXfactorBrake(double value) => xFactorBrake = value;
  double onChangedXfactorThrottle(double value) => xFactorThrottle = value;
  double onChangedYfactorLeft(double value) => yFactorLeft = value;
  double onChangedYfactorRight(double value) => yFactorRight = value;

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
      outMin: -255 * xFactorBrake,
      outMax: 255 * xFactorThrottle,
    );
    _vector2.y = Utils.scale(
      value: _vector2.y,
      inMin: -10,
      inMax: 10,
      outMin: -255 * yFactorLeft,
      outMax: 255 * yFactorRight,
    );
    sink.add(_vector2);
  }
}
