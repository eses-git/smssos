import 'package:sqflite/sqflite.dart';
import 'data_base.dart'; // Import your database class

class App {
  final String appId;
  final String email;
  final String phone;
  final DateTime dateCreation;
  final DateTime lastModification;
  final int activeAlarm;
  final String publicKey;

  App({
    required this.appId,
    required this.email,
    required this.phone,
    required this.dateCreation,
    required this.lastModification,
    required this.activeAlarm,
    required this.publicKey,
  });

  // Function to retrieve an App by appId
  static Future<App?> getAppById(String appId, Database database) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'app',
      where: 'appId = ?',
      whereArgs: [appId],
    );

    if (maps.isNotEmpty) {
      return App(
        appId: maps[0]['appId'],
        email: maps[0]['email'],
        phone: maps[0]['phone'],
        dateCreation: DateTime.parse(maps[0]['dateCreation']),
        lastModification: DateTime.parse(maps[0]['lastModification']),
        activeAlarm: maps[0]['activeAlarm'],
        publicKey: maps[0]['publicKey'],
      );
    } else {
      return null;
    }
  }

  // Function to update an App by appId
  static Future<void> updateAppById(App updatedApp, Database database) async {
    await database.update(
      'app',
      updatedApp.toMap(),
      where: 'appId = ?',
      whereArgs: [updatedApp.appId],
    );
  }

  // Function to insert an App into the database
  static Future<void> insertApp(App app, Database database) async {
    await database.insert('app', app.toMap());
  }

  // Helper method to convert App object to a map
  Map<String, dynamic> toMap() {
    return {
      'appId': appId,
      'email': email,
      'phone': phone,
      'dateCreation': dateCreation.toIso8601String(),
      'lastModification': lastModification.toIso8601String(),
      'activeAlarm': activeAlarm,
      'publicKey': publicKey,
    };
  }
}
