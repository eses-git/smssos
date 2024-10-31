import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/widgets.dart';
import 'app.dart';
import 'app_user.dart';
import 'app_alert_status.dart';
import 'app_alert_type.dart';
import 'app_settings.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';



class AppDataBase {
  late Database _database;
  bool _isInitialized = false;

  // Singleton instance
  static final AppDataBase _instance = AppDataBase._internal();
  factory AppDataBase() => _instance;
  AppDataBase._internal();

  // Ensure the database is initialized before accessing it
  Future<Database> get database async {
    if (!_isInitialized) {
      await init();
    }
    return _database;
  }

  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    final String databasePath = await getDatabasesPath();
    final String path = join(databasePath, 'caregiver.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
    _isInitialized = true; // Mark as initialized
    await _printTableNames();
    // Only insert data if the app table is empty
    final bool appTableIsEmpty = await _isAppTableEmpty();
    if (appTableIsEmpty) {
      await insertIntoAppTable();
      await insertIntoUserTable();
      await insertIntoAlertStatusTable();
      await insertIntoAppAlertType();
      await insertIntoAppSettings();
    }
  }


  Future<bool> _isAppTableEmpty() async {
    final List<Map<String, dynamic>> result = await _database.rawQuery('SELECT COUNT(*) FROM app');
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count == 0;
  }

  Future<void> _printTableValues() async {
    final List<Map<String, dynamic>> tables = await _database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );

    final tableNames = tables.map((row) => row['name'] as String).toList();

    print('Tables in the database:');
    for (final tableName in tableNames) {
      print('- $tableName');
    }
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app (
        appId TEXT PRIMARY KEY,
        email TEXT,
        phone TEXT,
        dateCreation DATETIME,
        lastModification DATETIME,
        activeAlarm INTEGER,
        publicKey TEXT
      )
    ''');

    // Create other tables (appContact, appAlertStatus, appUser, etc.)

    // Create the 'appContact' table
    await db.execute('''
        CREATE TABLE IF NOT EXISTS appContact (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          app_userId TEXT,
          number TEXT,
          publicKey TEXT,
          app_id TEXT,
          user_id TEXT,
          app_appId TEXT
        )
      ''');

    // Create the 'appAlertStatus' table
    await db.execute('''
        CREATE TABLE IF NOT EXISTS appAlertStatus (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL
        )
      ''');

    // Create the 'appUser' table
    await db.execute('''
        CREATE TABLE IF NOT EXISTS appUser (
          userId TEXT PRIMARY KEY,
          name TEXT,
          email TEXT,
          phone TEXT,
          dateCreation DATETIME,
          app_appId TEXT,
          publicKey TEXT,
          FOREIGN KEY (app_appId) REFERENCES app(appId)
        )
      ''');

    // Create the 'appSettings' table
    await db.execute('''
        CREATE TABLE IF NOT EXISTS appSettings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          app_userId TEXT,
          app_appId TEXT,
          isVoiceRecognition INTEGER,
          isLocationPermission INTEGER,
          isRecordingPermission INTEGER,
          viaWhatsApp INTEGER,
          viaSMS INTEGER,
          viaTelegram INTEGER,
          viaAPP INTEGER,
          lastUpdate DATETIME,
          voiceCmdActivate TEXT,
          voiceCmdCancel TEXT,
          FOREIGN KEY (app_appId) REFERENCES app(appId),
          FOREIGN KEY (app_userId) REFERENCES appUser(userId)
        )
      ''');

    // Create the 'appAlert' table
    await db.execute('''
        CREATE TABLE IF NOT EXISTS appAlert (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          dateTimeStart DATETIME,
          location TEXT,
          app_appId TEXT,
          app_userId TEXT,
          appAlertStatus_id INTEGER,
          recordingPathLocal TEXT,
          recordingUrlLocal TEXT,
          recordingUrlServer TEXT,
          appAlertType_id INTEGER,
          FOREIGN KEY (app_appId) REFERENCES app(appId),
          FOREIGN KEY (appAlertStatus_id) REFERENCES appAlertStatus(id),
          FOREIGN KEY (appAlertType_id) REFERENCES appAlertType(id),
          FOREIGN KEY (app_userId) REFERENCES appUser(userId)
        )
      ''');

    // Create the 'appAlertUpdate' table
    await db.execute('''
        CREATE TABLE IF NOT EXISTS appAlertUpdate (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          appAlert_id INTEGER,
          location TEXT,
          dateTime DATETIME,
          FOREIGN KEY (appAlert_id) REFERENCES appAlert(id)
        )
      ''');

    // Create the 'appAlertType' table
    await db.execute('''
        CREATE TABLE IF NOT EXISTS appAlertType (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL
        )
      ''');
    // Add their creation statements here...

  }

  Future<void> _printTableNames() async {
    final List<Map<String, dynamic>> tables = await _database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );

    final tableNames = tables.map((row) => row['name'] as String).toList();

    print('Tables in the database:');
    for (final tableName in tableNames) {
      print('- $tableName');
    }
  }

  Future<void> close() async {
    await _database.close();
  }

  Future<void> insertIntoAppTable() async {
    final appid = Uuid().v4();
    final secureStorage = FlutterSecureStorage();
    final publicKey = await secureStorage.read(key: 'appPublicKey');

    final myApp = App(
      appId: appid,
      email: '',
      phone: '',
      dateCreation: DateTime.now(),
      lastModification: DateTime.now(),
      activeAlarm: 0, // Set your desired value
      publicKey: '$publicKey',
    );
    await App.insertApp(myApp, _database);
    await secureStorage.write(key: 'appId', value: appid);
    print("insert of data sukces $appid:      and publicKey ------: $publicKey");
  }

  Future<void> insertIntoUserTable() async {
    final userid = Uuid().v4();
    final secureStorage = FlutterSecureStorage();
    final publicKey = await secureStorage.read(key: 'appPublicKey');
    final appId = await secureStorage.read(key:"appId");

    final myUser = AppUser(
      userId: userid,
      name: '',
      email: '',
      phone: '',
      dateCreation: DateTime.now(),
      appAppId: '$appId',
      publicKey: '$publicKey',
    );
    await AppUser.insertAppUser(myUser, _database);
    await secureStorage.write(key: 'userId', value: userid);
    print(" Data insered into User ,User ID $userid:      and publicKey ------: $publicKey");

  }

  Future<void> insertIntoAlertStatusTable() async{
    final alertStatus1 = AppAlertStatus(
        id: 1,
        name: 'Active'
    );
    final alertStatus2 = AppAlertStatus(
        id: 2,
        name: 'Canceled'
    );
    final alertStatus3 = AppAlertStatus(
        id: 3,
        name: 'Finished'
    );
    final alertStatus4 = AppAlertStatus(
        id: 4,
        name: 'Alarm test active'
    );
    final alertStatus5 = AppAlertStatus(
        id: 5,
        name: 'Alarm test canceled'
    );
    final alertStatus6 = AppAlertStatus(
        id: 6,
        name: 'Alarm test finished'
    );

    await AppAlertStatus.insertAppAlertStatus(alertStatus1, _database);
    await AppAlertStatus.insertAppAlertStatus(alertStatus2, _database);
    await AppAlertStatus.insertAppAlertStatus(alertStatus3, _database);
    await AppAlertStatus.insertAppAlertStatus(alertStatus4, _database);
    await AppAlertStatus.insertAppAlertStatus(alertStatus5, _database);
    await AppAlertStatus.insertAppAlertStatus(alertStatus6, _database);
    print(" Data insered into Alert status");
  }

  Future<void> insertIntoAppAlertType() async {
    final alertType1 = AppAlertType(
        id: 1,
        name: 'Secutiry alarm'
    );
    await AppAlertType.insertAppAlertType(alertType1, _database);
    print(" Data insered into Alert Type");
  }
  Future<void> insertIntoAppSettings() async {
    final secureStorage = FlutterSecureStorage();
    final appId = await secureStorage.read(key: 'appId');
    final userId = await secureStorage.read(key: 'userId');

    final isVoiceRecognition = await  secureStorage.write(key: 'isVoiceRecognition', value : 'false');
    final isLocationPermission = await  secureStorage.write(key: 'isLocationPermission', value : 'false');
    final isRecordingPermission = await  secureStorage.write(key: 'isRecordingPermission',value : 'false');
    final viaWhatsApp = await  secureStorage.write(key: 'viaWhatsApp', value : 'false');
    final viaSMS = await  secureStorage.write(key: 'viaSMS', value : 'false');
    final viaTelegram = await  secureStorage.write(key: 'viaTelegram', value : 'false');
    final viaAPP = await  secureStorage.write(key: 'viaAPP', value : 'false');

    final settings = AppSettings(
      id: 1,
      appUserId: '$userId',
      appAppId: '$appId',
      lastUpdate: DateTime.now(),
      voiceCmdActivate: '',
      voiceCmdCancel: '',
    );
    await AppSettings.insertAppSettings(settings, _database);
    print(" Data insered into Alert settings");

  }

}