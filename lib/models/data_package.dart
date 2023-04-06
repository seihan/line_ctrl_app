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

    if (values.length < 14) {
      //todo: fix this
      // length == 20
      // may wrong starting point and / or decode logic
      //throw const FormatException('Invalid number of values in package');
      return;
    }

    avgMotorCurrent = values[0];
    avgInputCurrent = values[1];
    dutyCycleNow = values[2];
    rpm = values[3];
    inpVoltage = values[4];
    ampHours = values[5];
    ampHoursCharged = values[6];
    wattHours = values[7];
    wattHoursCharged = values[8];
    tachometer = values[9]?.toInt();
    tachometerAbs = values[10]?.toInt();
    tempMosfet = values[11];
    tempMotor = values[12];
    pidPos = values[13];
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
    return 'DataPackage { avgMotorCurrent: $avgMotorCurrent, avgInputCurrent: $avgInputCurrent, '
        'dutyCycleNow: $dutyCycleNow, rpm: $rpm, inpVoltage: $inpVoltage, '
        'ampHours: $ampHours, ampHoursCharged: $ampHoursCharged, wattHours: $wattHours, '
        'wattHoursCharged: $wattHoursCharged, tachometer: $tachometer, '
        'tachometerAbs: $tachometerAbs, tempMosfet: $tempMosfet, tempMotor: $tempMotor, '
        'pidPos: $pidPos }';
  }
}
