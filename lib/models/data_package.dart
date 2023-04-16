import 'dart:typed_data';

class DataPackage {
  double? avgMotorCurrent;
  double? avgInputCurrent;
  double? dutyCycleNow;
  double? rpm;
  double? inpVoltage;
  double? ampHours;
  double? ampHoursCharged;
  double? wattHours;
  double? wattHoursCharged;
  int? tachometer;
  int? tachometerAbs;
  double? tempMosfet;
  double? tempMotor;
  double? pidPos;

  DataPackage(List<int> data) {
    List<double?> values = decodeValues(data);

    if (values.length != 5) {
      return;
    } else {
      final NotifyPackage package = NotifyPackage(
        identifier: values[0]?.toInt(),
        value_1: values[1],
        value_2: values[2],
        value_3: values[3],
        value_4: values[4],
      );
      switch (package.identifier) {
        case 0:
          {
            avgMotorCurrent = package.value_1;
            avgInputCurrent = package.value_2;
            dutyCycleNow = package.value_3;
            rpm = package.value_4;
          }
          break;
        case 1:
          {
            inpVoltage = package.value_1;
            ampHours = package.value_2;
            ampHoursCharged = package.value_3;
            wattHours = package.value_4;
          }
          break;
        case 2:
          {
            wattHoursCharged = package.value_1;
            tachometer = package.value_2?.toInt();
            tachometerAbs = package.value_3?.toInt();
            tempMosfet = package.value_4;
          }
          break;
        case 3:
          {
            tempMotor = package.value_1;
            pidPos = package.value_2;
          }
          break;
      }
    }
  }

  List<double?> decodeValues(List<int> data) {
    List<double?> values = [];

    for (int i = 0; i < data.length; i += 4) {
      // extract 4 bytes and convert to float
      int b1 = data[i];
      int b2 = data[i + 1];
      int b3 = data[i + 2];
      int b4 = data[i + 3];
      double? value = ByteData.view(Uint8List.fromList([b1, b2, b3, b4]).buffer)
          .getFloat32(0);

      if (value.isNaN == true || value.isInfinite == true) {
        value = null;
      }

      values.add(value);
    }

    return values;
  }

  @override
  String toString() {
    return 'avgMotorCurrent: $avgMotorCurrent, avgInputCurrent: $avgInputCurrent, '
        'dutyCycleNow: $dutyCycleNow, rpm: $rpm, inpVoltage: $inpVoltage, '
        'ampHours: $ampHours, ampHoursCharged: $ampHoursCharged, wattHours: $wattHours, '
        'wattHoursCharged: $wattHoursCharged, tachometer: $tachometer, '
        'tachometerAbs: $tachometerAbs, tempMosfet: $tempMosfet, tempMotor: $tempMotor, '
        'pidPos: $pidPos }';
  }
}

class NotifyPackage {
  final int? identifier;
  final double? value_1;
  final double? value_2;
  final double? value_3;
  final double? value_4;
  NotifyPackage({
    this.identifier,
    this.value_1,
    this.value_2,
    this.value_3,
    this.value_4,
  });
}
