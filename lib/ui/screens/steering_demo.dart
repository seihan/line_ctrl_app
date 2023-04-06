import 'package:flutter/material.dart';

import '../../models/bluetooth_connection_model.dart';
import '../widgets/accelerometer_bars.dart';

class SteeringDemo extends StatelessWidget {
  final BluetoothConnectionModel model;
  const SteeringDemo({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: const SafeArea(
        child: AccelerometerBars(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => model.startScan(),
        backgroundColor: model.isScanning ? Colors.red : Colors.green,
        child: Icon(model.isScanning ? Icons.stop : Icons.search),
      ),
    );
  }
}
