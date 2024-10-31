import 'package:sqflite/sqflite.dart';

class AppUser {
  final String userId;
  final String? name;      // Optional
  final String? email;     // Optional
  final String? phone;     // Optional
  final DateTime dateCreation;
  final String appAppId;   // Foreign key reference
  final String publicKey;

  AppUser({
    required this.userId,
    this.name,            // Optional
    this.email,           // Optional
    this.phone,           // Optional
    required this.dateCreation,
    required this.appAppId,
    required this.publicKey,
  });

  static Future<void> printAllAppUsers(Database database) async {
    // Query all the rows in the 'appUser' table
    final List<Map<String, dynamic>> maps = await database.query('appUser');

    // Check if the table is not empty
    if (maps.isNotEmpty) {
      print("AppUser table content:");

      // Loop through the list of maps and print each user's details
      for (var map in maps) {
        print("User ID: ${map['userId']}");
        print("Name: ${map['name']}");
        print("Email: ${map['email']}");
        print("Phone: ${map['phone']}");
        print("Date Creation: ${map['dateCreation']}");
        print("App ID (Foreign Key): ${map['app_appId']}");
        print("Public Key: ${map['publicKey']}");
        print("--------------------------------------");
      }
    } else {
      // If no records found, print this
      print("No users found in the appUser table.");
    }
  }

  // Function to retrieve an AppUser by userId
  static Future<AppUser?> getAppUserById(String userId, Database database) async {
    print("all users");
    printAllAppUsers(database);
    final List<Map<String, dynamic>> maps = await database.query(
      'appUser',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return AppUser(
        userId: maps[0]['userId'],
        name: maps[0]['name'],
        email: maps[0]['email'],
        phone: maps[0]['phone'],
        dateCreation: DateTime.parse(maps[0]['dateCreation']),
        appAppId: maps[0]['app_appId'],
        publicKey: maps[0]['publicKey'],
      );
    } else {
      return null;
    }
  }

  // Method to update user by userId
  static Future<void> updateAppUser(AppUser user, Database db) async {
    try {
      // Attempt to update the user record
      int result = await db.update(
        'appUser',
        user.toMap(),
        where: 'userId = ?',  // Specify the condition to update by userId
        whereArgs: [user.userId],
      );
      if (result > 0) {
        // If one or more rows were affected, update was successful
        print("User updated successfully: ${user.userId}");
      } else {
        // If no rows were affected, display an error message
        print("Error: User with ID ${user.userId} was not found or could not be updated.");
      }
    } catch (e) {
      // Handle any other exceptions (e.g., database issues)
      print("An error occurred while updating user: ${e.toString()}");
    }
  }


  // Function to insert an AppUser into the database
  static Future<void> insertAppUser(AppUser appUser, Database database) async {
    await database.insert('appUser', appUser.toMap());
  }

  // Helper method to convert AppUser object to a map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name ?? '',  // Handle null value for name
      'email': email ?? '', // Handle null value for email
      'phone': phone ?? '', // Handle null value for phone
      'dateCreation': dateCreation.toIso8601String(),
      'app_appId': appAppId,
      'publicKey': publicKey,
    };
  }
}
