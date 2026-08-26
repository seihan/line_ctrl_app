import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// This enum will manage the overall state of the app
enum PermissionSection {
  noLocationPermission, // Permission denied, but not forever
  noLocationPermissionPermanent, // Permission denied forever
  // API 31 Android 12+
  noBluetoothScanPermission, // Permission denied, but not forever
  noBluetoothScanPermissionPermanent, // Permission denied forever
  permissionGranted, // Permission granted
  unknown, // Permission unknown
}

class PermissionModel extends ChangeNotifier {
  static final PermissionModel _instance = PermissionModel._internal();
  PermissionModel._internal();
  factory PermissionModel() {
    return _instance;
  }
  PermissionSection _permissionSection = PermissionSection.unknown;

  bool _locationPermissionGranted = false;
  bool _bluetoothPermissionGranted = false;

  PermissionSection get permissionSection => _permissionSection;

  set permissionSection(PermissionSection value) {
    if (value != _permissionSection) {
      _permissionSection = value;
      notifyListeners();
    }
  }

  Future<bool> requestLocationPermission() async {
    final result = await Permission.location.request();

    if (result.isGranted) {
      _locationPermissionGranted = true;
    } else if (result.isPermanentlyDenied) {
      _locationPermissionGranted = false;
      permissionSection = PermissionSection.noLocationPermissionPermanent;
    } else {
      _locationPermissionGranted = false;
      permissionSection = PermissionSection.noLocationPermission;
    }
    _updateOverallPermissionStatus();
    return _locationPermissionGranted;
  }

  Future<bool> requestBluetoothScanPermission() async {
    final result = await Permission.bluetoothScan.request();

    if (result.isGranted) {
      _bluetoothPermissionGranted = true;
    } else if (result.isPermanentlyDenied) {
      _bluetoothPermissionGranted = false;
      permissionSection = PermissionSection.noBluetoothScanPermissionPermanent;
    } else {
      _bluetoothPermissionGranted = false;
      permissionSection = PermissionSection.noBluetoothScanPermission;
    }
    _updateOverallPermissionStatus();
    return _bluetoothPermissionGranted;
  }

  void _updateOverallPermissionStatus() {
    if (_locationPermissionGranted && _bluetoothPermissionGranted) {
      permissionSection = PermissionSection.permissionGranted;
    }
  }
}
