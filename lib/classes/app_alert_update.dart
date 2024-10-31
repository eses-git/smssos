import 'package:sqflite/sqflite.dart';

class AppAlertUpdate {
  final int id;
  final int appAlertId; // Foreign key reference
  final String location;
  final DateTime dateTime;

  AppAlertUpdate({
    required this.id,
    required this.appAlertId,
    required this.location,
    required this.dateTime,
  });

  // Function to retrieve an AppAlertUpdate by ID
  static Future<AppAlertUpdate?> getAppAlertUpdateById(int updateId, Database database) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'appAlertUpdate',
      where: 'id = ?',
      whereArgs: [updateId],
    );

    if (maps.isNotEmpty) {
      return AppAlertUpdate(
        id: maps[0]['id'],
        appAlertId: maps[0]['appAlert_id'],
        location: maps[0]['location'],
        dateTime: DateTime.parse(maps[0]['dateTime']),
      );
    } else {
      return null;
    }
  }

  // Function to insert an AppAlertUpdate into the database
  static Future<void> insertAppAlertUpdate(AppAlertUpdate alertUpdate, Database database) async {
    await database.insert('appAlertUpdate', alertUpdate.toMap());
  }

  // Helper method to convert AppAlertUpdate object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'appAlert_id': appAlertId,
      'location': location,
      'dateTime': dateTime.toIso8601String(),
    };
  }
}
