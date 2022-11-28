import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:line_ctrl_app/controller/line_controller.dart';
import 'package:line_ctrl_app/ui/widgets/control_button.dart';
import 'package:line_ctrl_app/ui/widgets/control_buttons.dart';
import 'package:line_ctrl_app/ui/widgets/data_view.dart';

import '../controller/sensor_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late LineController _lineController;
  SensorController? _sensorController;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    if (!_initialized) {
      _lineController = LineController();
      _sensorController = SensorController();
      _lineController.init();
      _initialized = true;
    }
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BluetoothDevice>>(
      stream: Stream.periodic(const Duration(seconds: 2))
          .asyncMap((_) => FlutterBluePlus.instance.connectedDevices),
      initialData: const [],
      builder: (c, snapshot) =>
          (snapshot.hasData && (snapshot.data?.isNotEmpty ?? false))
              ? Scaffold(
                  body: SafeArea(
                    child: Stack(
                      children: <Widget>[
                        Column(
                          children: [
                            Text('device name: ${snapshot.data?.first.name}'),
                            Row(
                              children: [
                                ControlButton(
                                  icon: Icons.close,
                                  size: 50,
                                  onPressed: () =>
                                      snapshot.data?.first.disconnect(),
                                ),
                                ControlButton(
                                  icon: Icons.bluetooth,
                                  size: 50,
                                  onPressed: _lineController.toggleNotify,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(30),
                          alignment: Alignment.bottomLeft,
                          child: ControlButtons(
                            title: 'left motor',
                            value: _lineController.leftValue,
                            size: 69,
                            active: _lineController.paused,
                            up: _lineController.leftUp,
                            down: _lineController.leftDown,
                            left: _lineController.leftLeft,
                            right: _lineController.leftRight,
                            middle: _lineController.leftStop,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(30),
                          alignment: Alignment.bottomRight,
                          child: ControlButtons(
                            title: 'right motor',
                            value: _lineController.rightValue,
                            size: 69,
                            active: _lineController.paused,
                            up: _lineController.rightUp,
                            down: _lineController.rightDown,
                            left: _lineController.rightLeft,
                            right: _lineController.rightRight,
                            middle: _lineController.rightStop,
                          ),
                        ),
                      ],
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: _lineController.togglePause,
                    child: Icon(
                      _lineController.paused ? Icons.play_arrow : Icons.pause,
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

  @override
  void dispose() {
    _lineController.dispose();
    super.dispose();
  }
}
