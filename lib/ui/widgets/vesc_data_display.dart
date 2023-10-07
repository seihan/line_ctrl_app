import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/vesc_state_model.dart';

class VescDataDisplay extends StatelessWidget {
  const VescDataDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the Consumer widget to listen to changes in the VescStateModel
    return Consumer<VescStateModel>(
      builder: (context, vescState, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Average Input Current: ${vescState.avgInputCurrent.toStringAsFixed(6)}',
            ),
            Text(
              'Average Motor Current: ${vescState.avgMotorCurrent.toStringAsFixed(6)}',
            ),
            Text(
              'Duty Cycle Now: ${vescState.dutyCycleNow.toStringAsFixed(3)}',
            ),
            Text(
              'RPM: ${vescState.rpm.toStringAsFixed(3)}',
            ),
            Text(
              'Input Voltage: ${vescState.inpVoltage.toStringAsFixed(3)}',
            ),
            Text(
              'Amp Hours: ${vescState.ampHours.toStringAsFixed(6)}',
            ),
            Text(
              'Amp Hours Charged: ${vescState.ampHoursCharged.toStringAsFixed(6)}',
            ),
            Text(
              'Watt Hours: ${vescState.wattHours.toStringAsFixed(6)}',
            ),
            Text(
              'Watt Hours Charged: ${vescState.wattHoursCharged.toStringAsFixed(6)}',
            ),
            Text('Tachometer: ${vescState.tachometer}'),
            Text('Tachometer Absolute: ${vescState.tachometerAbs}'),
            Text(
              'Temperature Mosfet: ${vescState.tempMosfet.toStringAsFixed(3)}',
            ),
            Text(
              'Temperature Motor: ${vescState.tempMotor.toStringAsFixed(3)}',
            ),
            Text(
              'PID Position: ${vescState.pidPos.toStringAsFixed(3)}',
            ),
          ],
        );
      },
    );
  }
}
