import 'dart:io';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../classes/app_my_command.dart';
import '../classes/app_my_command_sample.dart';
import '../classes/data_base.dart';

// Main function to handle preparing and sending data for training
Future<void> trainMe(String appMyCommandId) async {
  // Step 1: Retrieve command and sample data from the database
  final command = await _getCommand(appMyCommandId);
  if (command == null) {
    print("Command not found.");
    return;
  }
  final samples = await _getSamples(appMyCommandId);
  if (samples.isEmpty) {
    print("No samples available for this command.");
    return;
  }

  // Step 2: Zip the audio files for efficient transfer
  final zipFile = await _createZipFile(samples, appMyCommandId);

  // Step 3: Prepare metadata and send the zip file and metadata to the server
  await _sendDataToServer(zipFile, {
    "appId": command.appAppId ?? "defaultAppId", // Fallback to avoid null issues
    "appMyCommandId": appMyCommandId,
  });
}

// Retrieve the command record from the database based on appMyCommandId
Future<AppMyCommand?> _getCommand(String commandId) async {
  final db = await AppDataBase().database;
  return await AppMyCommand.getById(commandId, db);
}

// Retrieve all associated sample records for the given appMyCommandId
Future<List<AppMyCommandSample>> _getSamples(String commandId) async {
  final db = await AppDataBase().database;
  final List<Map<String, dynamic>> maps = await db.query(
    'appMyCommandSample',
    where: 'appMyCommandId = ?',
    whereArgs: [commandId],
  );
  return maps.map((map) {
    return AppMyCommandSample(
      appMyCommandId: map['appMyCommandId'],
      appMyCommandSampleId: map['appMyCommandSampleId'],
      appAppId: map['app_appId'],
      path: map['path'],
      dateTimeCreation: map['dateTimeCreation'] != null
          ? DateTime.parse(map['dateTimeCreation'])
          : null,
    );
  }).toList();
}

// Create a ZIP file of all audio samples for this command
Future<File> _createZipFile(List<AppMyCommandSample> samples, String commandId) async {
  final tempDir = await getTemporaryDirectory();
  final zipFile = File('${tempDir.path}/${commandId}_audio_data.zip');

  final archiveDir = Directory('${tempDir.path}/${commandId}_audio_files');
  await archiveDir.create(recursive: true);

  // Copy each audio sample into a temporary folder before zipping
  for (var sample in samples) {
    if (sample.path == null) continue; // Skip null paths
    final audioFile = File(sample.path!);
    if (await audioFile.exists()) {
      await audioFile.copy('${archiveDir.path}/${audioFile.uri.pathSegments.last}');
    } else {
      print("File not found: ${sample.path}");
    }
  }

  // Create the ZIP file from the directory with the audio samples
  await ZipFile.createFromDirectory(
    sourceDir: archiveDir,
    zipFile: zipFile,
    includeBaseDirectory: false,
  );
  await archiveDir.delete(recursive: true); // Clean up temp files after zipping

  return zipFile;
}

// Send the data to the server
Future<void> _sendDataToServer(File zipFile, Map<String, String> requestData) async {
  final uri = Uri.parse("http://192.168.0.103:8001/upload_and_train");

  print("Sending request to server:");
  print("URI: $uri");
  print("Metadata: $requestData");
  print("ZIP file: ${zipFile.path}, size: ${await zipFile.length()} bytes");

  // Create a multipart POST request
  final request = http.MultipartRequest("POST", uri)
    ..fields.addAll(requestData) // Add the fields (appId and appMyCommandId)
    ..files.add(await http.MultipartFile.fromPath('file', zipFile.path));

  // Send the request and handle the response
  try {
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      print("Upload successful!");
      print("Response body: $responseBody");
    } else {
      print("Upload failed with status: ${response.statusCode}");
      print("Response body: $responseBody");
    }
  } catch (e) {
    print("Error while sending data: $e");
  }
}
