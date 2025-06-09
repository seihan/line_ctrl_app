import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vector_math/vector_math.dart';

import '../utils.dart';

class SensorController extends ChangeNotifier {
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
    _vector2.x = Utils.reScale(
      value: _vector2.x,
      inMin: -10,
      inMax: 10,
      outMin: -255,
      outMax: 255,
    );
    _vector2.y = Utils.reScale(
      value: _vector2.y,
      inMin: -10,
      inMax: 10,
      outMin: -255,
      outMax: 255,
    );
    sink.add(_vector2);
  }
}
