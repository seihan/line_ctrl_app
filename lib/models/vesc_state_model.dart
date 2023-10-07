import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class VescStateModel extends ChangeNotifier {
  static final VescStateModel _instance = VescStateModel._internal();
  VescStateModel._internal();

  factory VescStateModel() {
    return _instance;
  }

  final StreamController<VescStateModel> _controller =
      StreamController.broadcast();
  Stream<VescStateModel> get stateStream => _controller.stream;

  double _avgMotorCurrent = 0;
  double _avgInputCurrent = 0;
  double _dutyCycleNow = 0;
  double _rpm = 0;
  double _inpVoltage = 0;
  double _ampHours = 0;
  double _ampHoursCharged = 0;
  double _wattHours = 0;
  double _wattHoursCharged = 0;
  int _tachometer = 0;
  int _tachometerAbs = 0;
  double _tempMosfet = 0;
  double _tempMotor = 0;
  double _pidPos = 0;

  double get avgInputCurrent => _avgInputCurrent;

  double get avgMotorCurrent => _avgMotorCurrent;

  double get dutyCycleNow => _dutyCycleNow;

  double get rpm => _rpm;

  double get inpVoltage => _inpVoltage;

  double get ampHours => _ampHours;

  double get ampHoursCharged => _ampHoursCharged;

  double get wattHours => _wattHours;

  double get wattHoursCharged => _wattHoursCharged;

  int get tachometer => _tachometer;

  int get tachometerAbs => _tachometerAbs;

  double get tempMosfet => _tempMosfet;

  double get tempMotor => _tempMotor;

  double get pidPos => _pidPos;

  update(List<int> data) {
    var buffer = ByteData.view(Uint8List.fromList(data).buffer);
    int identifier = buffer.getInt32(0, Endian.little);

    switch (identifier) {
      case 0:
        {
          _avgMotorCurrent = buffer.getFloat32(4, Endian.little);
          _avgInputCurrent = buffer.getFloat32(8, Endian.little);
          _dutyCycleNow = buffer.getFloat32(12, Endian.little);
          _rpm = buffer.getFloat32(16, Endian.little);
          break;
        }
      case 1:
        {
          _inpVoltage = buffer.getFloat32(4, Endian.little);
          _ampHours = buffer.getFloat32(8, Endian.little);
          _ampHoursCharged = buffer.getFloat32(12, Endian.little);
          _wattHours = buffer.getFloat32(16, Endian.little);
          break;
        }
      case 2:
        {
          _wattHoursCharged = buffer.getFloat32(4, Endian.little);
          _tachometer = buffer.getInt32(8, Endian.little);
          _tachometerAbs = buffer.getInt32(12, Endian.little);
          _tempMosfet = buffer.getFloat32(16, Endian.little);
          break;
        }
      case 3:
        {
          _tempMotor = buffer.getFloat32(4, Endian.little);
          _pidPos = buffer.getFloat32(8, Endian.little);
          break;
        }
    }
    _controller.add(this);
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}
