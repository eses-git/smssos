
import 'package:flutter/material.dart';
import '../classes/settings.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> setVoiceCmdActivate(String value)async {

  final secureStorage = FlutterSecureStorage();
  final settings =  Settings();
  settings.setVoiceCmdActivate(value);

}
Future<void> setVoiceCmdCancel(String value)async {

  final secureStorage = FlutterSecureStorage();
  final settings =  Settings();
  settings.setVoiceCmdCancel(value);

}

Future<String?> getVoiceCmdActivate(String value) async {
  final secureStorage = FlutterSecureStorage();
  final settings = Settings();

  return await settings.getVoiceCmdActivate(); // Return the value
}


Future<String?> getVoiceCmdCancel(String value) async {
  final secureStorage = FlutterSecureStorage();
  final settings = Settings();

  return await settings.getVoiceCmdCancel(); // Return the value
}
