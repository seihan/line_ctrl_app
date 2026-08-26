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
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Average Input Current: ${vescState.avgInputCurrent.toStringAsFixed(3)}',
                ),
                Text(
                  'Average Motor Current: ${vescState.avgMotorCurrent.toStringAsFixed(3)}',
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
                  'Amp Hours: ${vescState.ampHours.toStringAsFixed(3)}',
                ),
                Text(
                  'Amp Hours Charged: ${vescState.ampHoursCharged.toStringAsFixed(3)}',
                ),
                Text(
                  'Watt Hours: ${vescState.wattHours.toStringAsFixed(3)}',
                ),
                Text(
                  'Watt Hours Charged: ${vescState.wattHoursCharged.toStringAsFixed(3)}',
                ),
                Text('Tachometer: ${vescState.tachometer}'),
              ],
            ),
            const SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  'Steering Left Limit: ${vescState.steeringLeftLimit}',
                ),
                Text(
                  'Steering Left Forward: ${vescState.steeringLeftForward}',
                ),
                Text(
                  'Steering Right Limit: ${vescState.steeringRightLimit}',
                ),
                Text(
                  'Steering Right Forward: ${vescState.steeringRightForward}',
                ),
                Text(
                  'Steering Left Speed: ${vescState.steeringLeftSpeed}',
                ),
                Text(
                  'Steering Right Speed: ${vescState.steeringRightSpeed}',
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
