import 'package:sqflite/sqflite.dart';

class AppAlertType {
  final int id;
  final String name;

  AppAlertType({
    required this.id,
    required this.name,
  });

  // Function to retrieve an AppAlertType by ID
  static Future<AppAlertType?> getAppAlertTypeById(int typeId, Database database) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'appAlertType',
      where: 'id = ?',
      whereArgs: [typeId],
    );

    if (maps.isNotEmpty) {
      return AppAlertType(
        id: maps[0]['id'],
        name: maps[0]['name'],
      );
    } else {
      return null;
    }
  }

  // Function to insert an AppAlertType into the database
  static Future<void> insertAppAlertType(AppAlertType alertType, Database database) async {
    await database.insert('appAlertType', alertType.toMap());
  }

  // Helper method to convert AppAlertType object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
