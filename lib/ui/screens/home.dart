import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:line_ctrl_app/controller/bluetooth_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final BluetoothController controller;

  @override
  void initState() {
    controller = BluetoothController();
    controller.init();
    controller.startScan();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    child: const Text("push left"),
                    onPressed: () async => controller.write(
                        type: ControllerType.left, value: "100"),
                  onLongPress: () async => controller.write(
                        type: ControllerType.left, value: "100"),
                  ),
                  TextButton(
                    child: const Text("push power"),
                    onPressed: () async => controller.write(
                        type: ControllerType.power, value: "100"),
                  ),
                  TextButton(
                    child: const Text("push right"),
                    onPressed: () async => controller.write(
                        type: ControllerType.right, value: "100"),
                  ),
                ],
              ),

      ),
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
    );
  }
}
