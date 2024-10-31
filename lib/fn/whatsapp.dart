import 'package:flutter/material.dart';
import '../classes/settings.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


Future<void> allowWhatsApp(bool value) async {
  final secureStorage = FlutterSecureStorage();
  final settings =  Settings();
  settings.setViaWhatsApp(value);

}