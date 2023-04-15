import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/bluetooth_connection_model.dart';
import '../../models/steering_model.dart';
import '../widgets/accelerometer_bars.dart';
import '../widgets/control_slider.dart';

class SteeringDemo extends StatelessWidget {
  final BluetoothConnectionModel model;
  const SteeringDemo({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            const AccelerometerBars(),
            ChangeNotifierProvider<SteeringModel>(
              create: (_) => SteeringModel(connectionModel: model),
              child: Consumer<SteeringModel>(
                builder: (context, model, child) {
                  return Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(top: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ControlSlider(
                          title: 'Left',
                          value: model.leftValue.toDouble(),
                          active: model.activeLeft,
                          onChanged: model.onChangedLeft,
                          onPressed: model.toggleLeft,
                        ),
                        ControlSlider(
                          title: 'Power',
                          value: model.powerValue.toDouble(),
                          active: model.activePower,
                          onChanged: model.onChangedPower,
                          onPressed: model.togglePower,
                        ),
                        ControlSlider(
                          title: 'Right',
                          value: model.rightValue.toDouble(),
                          active: model.activeRight,
                          onChanged: model.onChangedRight,
                          onPressed: model.toggleRight,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => model.startScan(),
        backgroundColor: model.isScanning ? Colors.red : Colors.green,
        child: Icon(model.isScanning ? Icons.stop : Icons.search),
      ),
    );
  }
}
