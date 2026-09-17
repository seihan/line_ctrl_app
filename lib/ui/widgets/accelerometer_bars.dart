import 'package:flutter/material.dart';

import '../../models/sensor_model.dart';
import 'data_view.dart';

class AccelerometerBars extends StatelessWidget {
  const AccelerometerBars({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DataView(
      stream: SensorModel().vector2Ui,
    );
  }
}
