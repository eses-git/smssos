import 'package:sqflite/sqflite.dart';

class AppMyCommand {
  final String appMyCommandId;
  final String appAppId;
  final String? name;
  final String? modelName;
  final String? modelPath;
  final String? samplePath;
  final String? desc;
  final String? status;
  final String? type;
  final bool? isInUse;
  final bool? trained;
  final DateTime? dateTimeTraining;
  final DateTime? dateTimeCreation;
  final DateTime? lastUpdate;
  final int? sampleCount;

  AppMyCommand({
    required this.appMyCommandId,
    required this.appAppId,
    this.name,
    this.modelName,
    this.modelPath,
    this.samplePath,
    this.desc,
    this.status,
    this.type,
    this.isInUse,
    this.trained,
    this.dateTimeTraining,
    this.dateTimeCreation,
    this.lastUpdate,
    this.sampleCount,
  });

  // Add the copyWith method
  AppMyCommand copyWith({
    String? appMyCommandId,
    String? appAppId,
    String? name,
    String? modelName,
    String? modelPath,
    String? samplePath,
    String? desc,
    String? status,
    String? type,
    bool? isInUse,
    bool? trained,
    DateTime? dateTimeTraining,
    DateTime? dateTimeCreation,
    DateTime? lastUpdate,
    int? sampleCount,
  }) {
    return AppMyCommand(
      appMyCommandId: appMyCommandId ?? this.appMyCommandId,
      appAppId: appAppId ?? this.appAppId,
      name: name ?? this.name,
      modelName: modelName ?? this.modelName,
      modelPath: modelPath ?? this.modelPath,
      samplePath: samplePath ?? this.samplePath,
      desc: desc ?? this.desc,
      status: status ?? this.status,
      type: type ?? this.type,
      isInUse: isInUse ?? this.isInUse,
      trained: trained ?? this.trained,
      dateTimeTraining: dateTimeTraining ?? this.dateTimeTraining,
      dateTimeCreation: dateTimeCreation ?? this.dateTimeCreation,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      sampleCount: sampleCount ?? this.sampleCount,
    );
  }

  // Function to retrieve an AppMyCommand by appMyCommandId
  static Future<AppMyCommand?> getById(String appMyCommandId, Database database) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'appMyCommand',
      where: 'appMyCommandId = ?',
      whereArgs: [appMyCommandId],
    );

    if (maps.isNotEmpty) {
      final map = maps[0];
      return AppMyCommand(
        appMyCommandId: map['appMyCommandId'],
        appAppId: map['app_appId'],
        name: map['name'],
        modelName: map['modelName'],
        modelPath: map['modelPath'],
        samplePath: map['samplePath'],
        desc: map['desc'],
        status: map['status'],
        type: map['type'],
        isInUse: map['isInUse'] == 1,
        trained: map['trained'] == 1,
        dateTimeTraining: map['dateTimeTraining'] != null ? DateTime.parse(map['dateTimeTraining']) : null,
        dateTimeCreation: map['dateTimeCreation'] != null ? DateTime.parse(map['dateTimeCreation']) : null,
        lastUpdate: map['lastUpdate'] != null ? DateTime.parse(map['lastUpdate']) : null,
        sampleCount: map['sampleCount'],
      );
    } else {
      return null;
    }
  }

  // Function to insert an AppMyCommand into the database
  static Future<void> insert(AppMyCommand command, Database database) async {
    await database.insert('appMyCommand', command.toMap());
  }

  // Helper method to convert AppMyCommand object to a map
  Map<String, dynamic> toMap() {
    return {
      'appMyCommandId': appMyCommandId,
      'app_appId': appAppId,
      'name': name,
      'modelName': modelName,
      'modelPath': modelPath,
      'samplePath': samplePath,
      'desc': desc,
      'status': status,
      'type': type,
      'isInUse': isInUse == true ? 1 : 0,
      'trained': trained == true ? 1 : 0,
      'dateTimeTraining': dateTimeTraining?.toIso8601String(),
      'dateTimeCreation': dateTimeCreation?.toIso8601String(),
      'lastUpdate': lastUpdate?.toIso8601String(),
      'sampleCount': sampleCount,
    };
  }
}
