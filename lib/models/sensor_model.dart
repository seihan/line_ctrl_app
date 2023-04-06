import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sensors/sensors.dart';
import 'package:vector_math/vector_math.dart';

import '../utils.dart';

class SensorController extends ChangeNotifier {
  Vector2 _vector2 = Vector2.zero();

  Stream<Vector2> get vector2 => accelerometerEvents
      .throttleTime(const Duration(milliseconds: 33), trailing: true)
      .transform(
        StreamTransformer.fromHandlers(
          handleData: _transformAccelerometerEvent,
        ),
      );

  Vector2 _vecOf(AccelerometerEvent event) => Vector2(event.x, event.y);

  SensorController();

  void _transformAccelerometerEvent(
    AccelerometerEvent event,
    EventSink<Vector2> sink,
  ) {
    _vector2 = _vecOf(event);
    _vector2.x = Utils.reScale(
      value: _vector2.x,
      inMin: 0,
      inMax: 10,
      outMin: 255,
      outMax: 0,
    );
    _vector2.y = _vector2.y < 0
        ? Utils.reScale(
            value: _vector2.y,
            inMin: -10,
            inMax: 0,
            outMin: -255,
            outMax: 0,
          )
        : Utils.reScale(
            value: _vector2.y,
            inMin: 0,
            inMax: 10,
            outMin: 0,
            outMax: 255,
          );
    sink.add(_vector2);
  }
}
