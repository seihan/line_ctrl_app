import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// This enum will manage the overall state of the app
enum PermissionSection {
  noLocationPermission, // Permission denied, but not forever
  noLocationPermissionPermanent, // Permission denied forever
  permissionGranted, // Permission granted
  unknown, // Permission unknown
}

class PermissionModel extends ChangeNotifier {
  PermissionSection _permissionSection = PermissionSection.unknown;

  PermissionSection get permissionSection => _permissionSection;

  set permissionSection(PermissionSection value) {
    if (value != _permissionSection) {
      _permissionSection = value;
      notifyListeners();
    }
  }

  /// Request the location permission and updates the UI accordingly
  Future<bool> requestLocationPermission() async {
    PermissionStatus result;
    result = await Permission.location.request();

    if (result.isGranted) {
      permissionSection = PermissionSection.permissionGranted;
      return true;
    } else if (result.isPermanentlyDenied) {
      permissionSection = PermissionSection.noLocationPermissionPermanent;
    } else {
      permissionSection = PermissionSection.noLocationPermission;
    }
    return false;
  }
}
