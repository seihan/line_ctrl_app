import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:line_ctrl_app/controller/bluetooth_controller.dart';
import 'package:line_ctrl_app/controller/line_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final LineController _lineController;
  bool _initialized = false;

  @override
  void initState() {
    if (!_initialized) {
      _lineController = LineController();
      _lineController.init();
      _initialized = true;
    }
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.height / 2;
    return StreamBuilder<List<BluetoothDevice>>(
        stream: Stream.periodic(const Duration(seconds: 2))
            .asyncMap((_) => FlutterBlue.instance.connectedDevices),
        initialData: const [],
        builder: (c, snapshot) => snapshot.data!.isNotEmpty
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
                  onPressed: () => _lineController.togglePause(),
                  child: Icon(
                      _lineController.paused ? Icons.play_arrow : Icons.pause),
                ),
              )
            : Scaffold(
                body: const Center(child: CircularProgressIndicator()),
                floatingActionButton: StreamBuilder<bool>(
                  stream: FlutterBlue.instance.isScanning,
                  initialData: false,
                  builder: (c, snapshot) {
                    if (snapshot.data!) {
                      return FloatingActionButton(
                        child: const Icon(Icons.stop),
                        onPressed: () => FlutterBlue.instance.stopScan(),
                        backgroundColor: Colors.red,
                      );
                    } else {
                      return FloatingActionButton(
                          child: const Icon(Icons.search),
                          onPressed: () => FlutterBlue.instance
                              .startScan(timeout: const Duration(seconds: 4)));
                    }
                  },
                ),
              ));
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
            SizedBox(
                height: size,
                width: size,
                child: ElevatedButton(
                    onPressed: _lineController.paused ? _fullPower : null,
                    child: const Icon(Icons.arrow_upward))),
            Row(
              children: [
                SizedBox(
                    height: size,
                    width: size,
                    child: ElevatedButton(
                        onPressed:
                            _lineController.paused ? _fullBackward : null,
                        child: const Icon(Icons.arrow_back))),
                const Spacer(),
                SizedBox(
                    height: size,
                    width: size,
                    child: ElevatedButton(
                        onPressed: _lineController.paused ? _fullStop : null,
                        child: const Icon(Icons.stop))),
                const Spacer(),
                SizedBox(
                    height: size,
                    width: size,
                    child: ElevatedButton(
                        onPressed: _lineController.paused ? _fullForward : null,
                        child: const Icon(Icons.arrow_forward))),
              ],
            ),
            SizedBox(
                height: size,
                width: size,
                child: ElevatedButton(
                    onPressed: _lineController.paused ? _fullBrake : null,
                    child: const Icon(Icons.arrow_downward))),
          ],
        ));
  }

  void _fullPower() {
    _lineController.write(type: ControllerType.power, value: 255);
  }

  void _fullBrake() {
    _lineController.write(type: ControllerType.power, value: -255);
  }

  void _fullForward() {
    _lineController.write(type: ControllerType.right, value: 255);
  }

  void _fullBackward() {
    _lineController.write(type: ControllerType.right, value: -255);
  }

  void _fullStop() {
    _lineController.write(type: ControllerType.right, value: 0);
  }

  @override
  void dispose() {
    _lineController.dispose();
    super.dispose();
  }
}
