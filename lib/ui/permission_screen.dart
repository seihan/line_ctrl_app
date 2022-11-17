import 'package:flutter/material.dart';
import 'package:line_ctrl_app/models/permission_model.dart';
import 'package:line_ctrl_app/ui/home.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({Key? key}) : super(key: key);

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with WidgetsBindingObserver {
  late final PermissionModel _permissionModel;
  bool _detectPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _permissionModel = PermissionModel();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _permissionModel.requestLocationPermission();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // This block of code is used in the event that the user
  // has denied the permission forever. Detects if the permission
  // has been granted when the user returns from the
  // permission system screen.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _detectPermission &&
        (_permissionModel.permissionSection ==
            PermissionSection.noLocationPermissionPermanent)) {
      _detectPermission = false;
      _permissionModel.requestLocationPermission();
    } else if (state == AppLifecycleState.paused &&
        _permissionModel.permissionSection ==
            PermissionSection.noLocationPermissionPermanent) {
      _detectPermission = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _permissionModel,
      child: Consumer<PermissionModel>(
        builder: (context, model, child) {
          Widget widget;

          switch (model.permissionSection) {
            case PermissionSection.noLocationPermission:
              widget = LocationPermissions(
                isPermanent: false,
                onPressed: _checkPermissions,
              );
              break;
            case PermissionSection.noLocationPermissionPermanent:
              widget = LocationPermissions(
                isPermanent: true,
                onPressed: _checkPermissions,
              );
              break;
            case PermissionSection.permissionGranted:
              widget = StartButton(onPressed: _goToHomeScreen);
              break;
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Handle permissions'),
            ),
            body: widget,
          );
        },
      ),
    );
  }

  /// Check if the pick file permission is granted,
  /// if it's not granted then request it.
  /// If it's granted then invoke the file picker
  Future<void> _checkPermissions() async {
    final hasLocationPermissions =
        await _permissionModel.requestLocationPermission();
    debugPrint('Location permission: $hasLocationPermissions');
  }

  /// Leave permissions screen and go to home screen
  /// There is no need to came back, that's why the
  /// route will be removed
  void _goToHomeScreen() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }
}

/// This widget will serve to inform the user in
/// case the permission has been denied. There is a
/// variable [isPermanent] to indicate whether the
/// permission has been denied forever or not.
class LocationPermissions extends StatelessWidget {
  final bool isPermanent;
  final VoidCallback onPressed;

  const LocationPermissions({
    Key? key,
    required this.isPermanent,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 24.0,
              right: 16.0,
            ),
            child: Text(
              'Location service permission',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 24.0,
              right: 16.0,
            ),
            child: const Text(
              'We need to request your permission for '
              'location service in order to use the app.',
              textAlign: TextAlign.center,
            ),
          ),
          if (isPermanent)
            Container(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 24.0,
                right: 16.0,
              ),
              child: const Text(
                'You need to give this permission from the system settings.',
                textAlign: TextAlign.center,
              ),
            ),
          Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 24.0,
              right: 16.0,
              bottom: 24.0,
            ),
            child: ElevatedButton(
              child: Text(isPermanent ? 'Open settings' : 'Allow access'),
              onPressed: () => isPermanent ? openAppSettings() : onPressed(),
            ),
          ),
        ],
      ),
    );
  }
}

/// This widget is simply the button to select
/// the image from the local file system.
class StartButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const StartButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 24.0,
                right: 16.0,
              ),
              child: Text(
                'Permissions are granted',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 24.0,
                right: 16.0,
              ),
              child: const Text(
                'Prepare yourself and push the button!',
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: onPressed,
              child: const Text('Let\'s start'),
            ),
          ],
        ),
      );
}
