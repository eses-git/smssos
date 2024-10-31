import 'package:sqflite/sqflite.dart';

class AppAlertStatus {
  final int id;
  final String name;

  AppAlertStatus({
    required this.id,
    required this.name,
  });

  // Function to retrieve an AppAlertStatus by ID
  static Future<AppAlertStatus?> getAppAlertStatusById(int statusId, Database database) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'appAlertStatus',
      where: 'id = ?',
      whereArgs: [statusId],
    );

    if (maps.isNotEmpty) {
      return AppAlertStatus(
        id: maps[0]['id'],
        name: maps[0]['name'],
      );
    } else {
      return null;
    }
  }

  // Function to insert an AppAlertStatus into the database
  static Future<void> insertAppAlertStatus(AppAlertStatus alertStatus, Database database) async {
    await database.insert('appAlertStatus', alertStatus.toMap());
  }

  // Helper method to convert AppAlertStatus object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
