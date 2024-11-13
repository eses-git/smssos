import 'package:sqflite/sqflite.dart';

class AppMyCommandSample {
  final String appMyCommandId;
  final String appMyCommandSampleId;
  final String appAppId;
  final String? fileName;
  final String? path;
  final DateTime? dateTimeCreation;

  AppMyCommandSample({
    required this.appMyCommandId,
    required this.appMyCommandSampleId,
    required this.appAppId,
    this.fileName,
    this.path,
    this.dateTimeCreation,
  });

  // Add the copyWith method
  AppMyCommandSample copyWith({
    String? appMyCommandId,
    String? appMyCommandSampleId,
    String? appAppId,
    String? fileName,
    String? path,
    DateTime? dateTimeCreation,
  }) {
    return AppMyCommandSample(
      appMyCommandId: appMyCommandId ?? this.appMyCommandId,
      appMyCommandSampleId: appMyCommandSampleId ?? this.appMyCommandSampleId,
      appAppId: appAppId ?? this.appAppId,
      fileName: fileName ?? this.fileName,
      path: path ?? this.path,
      dateTimeCreation: dateTimeCreation ?? this.dateTimeCreation,
    );
  }

  // Function to retrieve an AppMyCommandSample by appMyCommandSampleId
  static Future<AppMyCommandSample?> getById(String appMyCommandSampleId, Database database) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'appMyCommandSample',
      where: 'appMyCommandSampleId = ?',
      whereArgs: [appMyCommandSampleId],
    );

    if (maps.isNotEmpty) {
      final map = maps[0];
      return AppMyCommandSample(
        appMyCommandId: map['appMyCommandId'],
        appMyCommandSampleId: map['appMyCommandSampleId'],
        appAppId: map['app_appId'],
        fileName: map['fileName'],
        path: map['path'],
        dateTimeCreation: map['dateTimeCreation'] != null ? DateTime.parse(map['dateTimeCreation']) : null,
      );
    } else {
      return null;
    }
  }

  // Function to insert an AppMyCommandSample into the database
  static Future<void> insert(AppMyCommandSample sample, Database database) async {
    await database.insert('appMyCommandSample', sample.toMap());
  }

  // Helper method to convert AppMyCommandSample object to a map
  Map<String, dynamic> toMap() {
    return {
      'appMyCommandId': appMyCommandId,
      'appMyCommandSampleId': appMyCommandSampleId,
      'app_appId': appAppId,
      'fileName': fileName,
      'path': path,
      'dateTimeCreation': dateTimeCreation?.toIso8601String(),
    };
  }
}
