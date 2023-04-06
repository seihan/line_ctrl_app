import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/sensor_model.dart';
import 'data_view.dart';

class AccelerometerBars extends StatelessWidget {
  const AccelerometerBars({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorController>(
      builder: (context, model, child) {
        return DataView(
          stream: model.vector2,
        );
      },
    );
  }
}
