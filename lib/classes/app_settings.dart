import 'package:sqflite/sqflite.dart';

class AppSettings {
  final int id;
  final String appUserId; // Foreign key reference
  final String appAppId; // Foreign key reference
  final DateTime lastUpdate;
  final String voiceCmdActivate;
  final String voiceCmdCancel;

  AppSettings({
    required this.id,
    required this.appUserId,
    required this.appAppId,
    required this.lastUpdate,
    required this.voiceCmdActivate,
    required this.voiceCmdCancel,
  });

  // Function to retrieve AppSettings by ID
  static Future<AppSettings?> getAppSettingsById(int settingsId, Database database) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'appSettings',
      where: 'id = ?',
      whereArgs: [settingsId],
    );
    if (maps.isNotEmpty) {
      return AppSettings(
        id: maps[0]['id'],
        appUserId: maps[0]['app_userId'],
        appAppId: maps[0]['app_appId'],
        lastUpdate: DateTime.parse(maps[0]['lastUpdate']),
        voiceCmdActivate: maps[0]['voiceCmdActivate'],
        voiceCmdCancel: maps[0]['voiceCmdCancel'],
      );
    } else {
      return null;
    }
  }
  static Future<AppSettings?> getAppSettingsByAppId(String appId, Database database) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'appSettings',
      where: 'app_appId = ?', // Use 'app_appId' column for matching
      whereArgs: [appId],
    );
    print("$appId ------ $database");
    if (maps.isNotEmpty) {
      return AppSettings(
        id: maps[0]['id'],
        appUserId: maps[0]['app_userId'],
        appAppId: maps[0]['app_appId'],
        lastUpdate: DateTime.parse(maps[0]['lastUpdate']),
        voiceCmdActivate: maps[0]['voiceCmdActivate'],
        voiceCmdCancel: maps[0]['voiceCmdCancel'],
      );
    } else {
      return null;
    }
  }


  // Function to insert AppSettings into the database
  static Future<void> insertAppSettings(AppSettings appSettings, Database database) async {
    await database.insert('appSettings', appSettings.toMap());
  }

  // Helper method to convert AppSettings object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'app_userId': appUserId,
      'app_appId': appAppId,
      'lastUpdate': lastUpdate.toIso8601String(),
      'voiceCmdActivate': voiceCmdActivate,
      'voiceCmdCancel': voiceCmdCancel,
    };
  }
  AppSettings copyWith({
    int? id,
    String? appUserId,
    String? appAppId,
    DateTime? lastUpdate,
    String? voiceCmdActivate,
    String? voiceCmdCancel,
  }) {
    return AppSettings(
      id: id ?? this.id,
      appUserId: appUserId ?? this.appUserId,
      appAppId: appAppId ?? this.appAppId,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      voiceCmdActivate: voiceCmdActivate ?? this.voiceCmdActivate,
      voiceCmdCancel: voiceCmdCancel ?? this.voiceCmdCancel,
    );
  }
}
