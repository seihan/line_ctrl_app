import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class AppDialogs {
  static final AppDialogs _instance = AppDialogs._internal();
  AppDialogs._internal();
  factory AppDialogs() {
    return _instance;
  }
  // must be delegated to material app
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> showBluetoothAdapterStateAlert() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return const BluetoothAdapterStateAlertDialog();
        },
      );
    }
    return Future.value();
  }
}

class BluetoothAdapterStateAlertDialog extends StatelessWidget {
  const BluetoothAdapterStateAlertDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bluetooth is turned off.'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async => await FlutterBluePlus.turnOn().then(
            (onValue) => context.mounted ? Navigator.of(context).pop() : null,
          ),
          child: const Text('Turn on'),
        ),
      ],
    );
  }
}
