import 'package:sqflite/sqflite.dart';

class AppContact {
  final int? id; // Make id nullable
  final String name;
  final String? appUserId; // Make optional
  final String number;
  final String? publicKey; // Make optional
  final String? appAppId; // Make optional
  final String? appId; // New field
  final String? userId; // New field

  AppContact({
    this.id, // Make id optional
    required this.name,
    this.appUserId, // Make optional
    required this.number,
    this.publicKey, // Make optional
    this.appAppId, // Make optional
    this.appId, // New field
    this.userId, // New field
  });

  // Function to retrieve an AppContact by ID
  static Future<AppContact?> getAppContactById(int contactId, Database database) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'appContact',
      where: 'id = ?',
      whereArgs: [contactId],
    );

    if (maps.isNotEmpty) {
      return AppContact(
        id: maps[0]['id'],
        name: maps[0]['name'],
        appUserId: maps[0]['app_user_id'],
        number: maps[0]['number'],
        publicKey: maps[0]['public_key'],
        appAppId: maps[0]['app_app_id'],
        appId: maps[0]['app_id'], // New field
        userId: maps[0]['user_id'], // New field
      );
    } else {
      return null;
    }
  }

  // Function to insert an AppContact into the database
  static Future<void> insertAppContact(AppContact appContact, Database database) async {
    try {
      await database.insert('appContact', appContact.toMap(excludeId: true));
      print('Contact inserted successfully');
    } catch (e) {
      print('Error inserting contact: $e');
    }
  }

  // Function to update an AppContact by ID
  static Future<void> updateAppContact(AppContact appContact, Database database) async {
    await database.update(
      'appContact',
      appContact.toMap(),
      where: 'id = ?',
      whereArgs: [appContact.id],
    );
  }

  // **Function to delete an AppContact by ID**
  static Future<void> deleteContact(int contactId, Database database) async {
    try {
      final result = await database.delete(
        'appContact',
        where: 'id = ?',
        whereArgs: [contactId],
      );
      if (result > 0) {
        print('Contact with ID $contactId deleted successfully.');
      } else {
        print('Contact with ID $contactId not found.');
      }
    } catch (e) {
      print('Error deleting contact: $e');
    }
  }

  // Function to retrieve all AppContacts
  static Future<List<AppContact>> getAllContacts(Database database) async {
    final List<Map<String, dynamic>> maps = await database.query('appContact');

    return List.generate(maps.length, (i) {
      return AppContact(
        id: maps[i]['id'],
        name: maps[i]['name'],
        appUserId: maps[i]['app_user_id'],
        number: maps[i]['number'],
        publicKey: maps[i]['public_key'],
        appAppId: maps[i]['app_app_id'],
        appId: maps[i]['app_id'], // New field
        userId: maps[i]['user_id'], // New field
      );
    });
  }

  // Function to print all AppContacts
  static Future<void> printAllContacts(Database database) async {
    final List<AppContact> contacts = await getAllContacts(database);
    for (var contact in contacts) {
      print('ID: ${contact.id}, Name: ${contact.name}, Number: ${contact.number}');
    }
  }

  // Helper method to convert AppContact object to a map
  Map<String, dynamic> toMap({bool excludeId = false}) {
    final map = {
      'name': name,
      'app_userId': appUserId,
      'number': number,
      'publicKey': publicKey,
      'app_appId': appAppId,
      'app_id': appId, // New field
      'user_id': userId, // New field
    };
    if (!excludeId && id != null) {
      map['id'] = '$id';
    }
    return map;
  }
}
