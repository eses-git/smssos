import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../classes/settings.dart';


Future<void> saveLocationPermission(bool value) async {

  final secureStorage = FlutterSecureStorage();
  final settings =  Settings();
  settings.setIsLocationPermission(value);

}

Future<void> allowLocation(BuildContext context, bool value) async {
  if (value) {
    // Check the current status of the location permission
    PermissionStatus currentStatus = await Permission.location.status;
    print("Current location permission status: $currentStatus");

    if (currentStatus.isDenied || currentStatus.isRestricted) {
      // If permission is denied or restricted, request the permission
      PermissionStatus status = await Permission.location.request();

      if (status.isGranted) {
        print("Location access granted.");
        saveLocationPermission(true);
      } else if (status.isDenied) {
        print("Location access denied.");
        _showGoToSettingsDialog(context);
      } else if (status.isPermanentlyDenied) {
        print("Location access permanently denied. You need to enable it from settings.");
        _showGoToSettingsDialog(context);
      }
    } else if (currentStatus.isPermanentlyDenied) {
      // If permanently denied, direct the user to app settings
      _showGoToSettingsDialog(context);
    } else if (currentStatus.isGranted) {
      // If already granted, no action needed
      saveLocationPermission(true);
      print("Location access is already granted.");
    }
  } else {
    // Handle the case when location access is turned off
    saveLocationPermission(false);
    print("Location access is turned off.");
  }
  print("Passed value: $value");
}

// Show a dialog to guide the user to app settings when permission is permanently denied
void _showGoToSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Permission Required"),
        content: Text("Location access is required for this feature. Please enable it in the app settings."),
        actions: <Widget>[
          // Button to open app settings
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings(); // Opens the app settings
            },
            child: Text("Open Settings"),
          ),
          // Cancel button
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
        ],
      );
    },
  );
}

