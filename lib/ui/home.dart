import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:line_ctrl_app/controller/bluetooth_controller.dart';
import 'package:line_ctrl_app/controller/line_controller.dart';
import 'package:line_ctrl_app/ui/widgets/control_button.dart';
import 'package:line_ctrl_app/ui/widgets/data_view.dart';

import '../controller/sensor_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LineController? _lineController;
  SensorController? _sensorController;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    if (!_initialized) {
      _lineController = LineController();
      _sensorController = SensorController();
      _lineController?.init();
      _initialized = true;
    }
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.height / 2;
    return StreamBuilder<List<BluetoothDevice>>(
      stream: Stream.periodic(const Duration(seconds: 2))
          .asyncMap((_) => FlutterBluePlus.instance.connectedDevices),
      initialData: const [],
      builder: (c, snapshot) =>
          (snapshot.hasData && (snapshot.data?.isNotEmpty ?? false))
              ? Scaffold(
                  body: Center(
                    child: SafeArea(
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        alignment: Alignment.bottomRight,
                        child: _controlButtons(width: width),
                      ),
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () => _lineController?.togglePause(),
                    child: Icon(
                      (_lineController?.paused ?? false)
                          ? Icons.play_arrow
                          : Icons.pause,
                    ),
                  ),
                )
              : Scaffold(
                  body: SafeArea(
                    child: Column(
                      children: <Widget>[
                        DataView(
                          stream: _sensorController?.vector2,
                        ),
                      ],
                    ),
                  ),
                  //CircularProgressIndicator()),
                  floatingActionButton: StreamBuilder<bool>(
                    stream: FlutterBluePlus.instance.isScanning,
                    initialData: false,
                    builder: (c, snapshot) {
                      if (snapshot.data ?? false) {
                        return FloatingActionButton(
                          onPressed: () => FlutterBluePlus.instance.stopScan(),
                          backgroundColor: Colors.red,
                          child: const Icon(Icons.stop),
                        );
                      } else {
                        return FloatingActionButton(
                          child: const Icon(Icons.search),
                          onPressed: () => FlutterBluePlus.instance
                              .startScan(timeout: const Duration(seconds: 4)),
                        );
                      }
                    },
                  ),
                ),
    );
  }

  Widget _controlButtons({double width = 150}) {
    const double size = 69;
    return SizedBox(
      height: 250,
      width: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ControlButton(
            icon: Icons.arrow_upward,
            size: size,
            onPressed: (_lineController?.paused ?? false) ? _fullPower : null,
          ),
          Row(
            children: [
              ControlButton(
                icon: Icons.arrow_back,
                size: size,
                onPressed:
                    (_lineController?.paused ?? false) ? _fullBackward : null,
              ),
              const Spacer(),
              ControlButton(
                icon: Icons.stop,
                size: size,
                onPressed:
                    (_lineController?.paused ?? false) ? _fullStop : null,
              ),
              const Spacer(),
              ControlButton(
                icon: Icons.arrow_forward,
                size: size,
                onPressed:
                    (_lineController?.paused ?? false) ? _fullForward : null,
              )
            ],
          ),
          ControlButton(
            icon: Icons.arrow_downward,
            size: size,
            onPressed: (_lineController?.paused ?? false) ? _fullBrake : null,
          ),
        ],
      ),
    );
  }

  void _fullPower() {
    _lineController?.write(type: ControllerType.power, value: 255);
  }

  void _fullBrake() {
    _lineController?.write(type: ControllerType.power, value: -255);
  }

  void _fullForward() {
    _lineController?.write(type: ControllerType.right, value: 255);
  }

  void _fullBackward() {
    _lineController?.write(type: ControllerType.right, value: -255);
  }

  void _fullStop() {
    _lineController?.write(type: ControllerType.right, value: 0);
  }

  @override
  void dispose() {
    _lineController?.dispose();
    super.dispose();
  }
}
