import 'package:sqflite/sqflite.dart';

class AppAlert {
  final int id;
  final DateTime dateTimeStart;
  final String location;
  final String appAppId; // Foreign key reference
  final String appUserId; // Foreign key reference
  final int appAlertStatusId; // Foreign key reference
  final String recordingPathLocal;
  final String recordingUrlLocal;
  final String recordingUrlServer;
  final int appAlertTypeId; // Foreign key reference

  AppAlert({
    required this.id,
    required this.dateTimeStart,
    required this.location,
    required this.appAppId,
    required this.appUserId,
    required this.appAlertStatusId,
    required this.recordingPathLocal,
    required this.recordingUrlLocal,
    required this.recordingUrlServer,
    required this.appAlertTypeId,
  });

  // Function to retrieve an AppAlert by ID
  static Future<AppAlert?> getAppAlertById(int alertId, Database database) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'appAlert',
      where: 'id = ?',
      whereArgs: [alertId],
    );

    if (maps.isNotEmpty) {
      return AppAlert(
        id: maps[0]['id'],
        dateTimeStart: DateTime.parse(maps[0]['dateTimeStart']),
        location: maps[0]['location'],
        appAppId: maps[0]['app_appId'],
        appUserId: maps[0]['app_userId'],
        appAlertStatusId: maps[0]['appAlertStatus_id'],
        recordingPathLocal: maps[0]['recordingPathLocal'],
        recordingUrlLocal: maps[0]['recordingUrlLocal'],
        recordingUrlServer: maps[0]['recordingUrlServer'],
        appAlertTypeId: maps[0]['appAlertType_id'],
      );
    } else {
      return null;
    }
  }

  // Function to insert an AppAlert into the database
  static Future<void> insertAppAlert(AppAlert appAlert, Database database) async {
    await database.insert('appAlert', appAlert.toMap());
  }

  // Helper method to convert AppAlert object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTimeStart': dateTimeStart.toIso8601String(),
      'location': location,
      'app_appId': appAppId,
      'app_userId': appUserId,
      'appAlertStatus_id': appAlertStatusId,
      'recordingPathLocal': recordingPathLocal,
      'recordingUrlLocal': recordingUrlLocal,
      'recordingUrlServer': recordingUrlServer,
      'appAlertType_id': appAlertTypeId,
    };
  }
}
