import 'package:flutter/material.dart';
import '../classes/settings.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


Future<void> allowSMS(bool value) async {
  final secureStorage = FlutterSecureStorage();
  final settings =  Settings();
  settings.setViaSMS(value);

}