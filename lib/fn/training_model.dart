import 'dart:io';

Future<String> getModelPath(String fileName) async {
  // Get the "commands" directory within the main project directory
  final directory = Directory.current.path;
  final commandsDirectory = Directory('$directory/commands');

  // Ensure the "commands" directory exists
  if (!commandsDirectory.existsSync()) {
    throw FileSystemException('Commands directory does not exist', commandsDirectory.path);
  }

  // Create the full path to the model file
  final filePath = '${commandsDirectory.path}/$fileName';
  final file = File(filePath);

  // Ensure the model file exists
  if (!file.existsSync()) {
    throw FileSystemException('Model file does not exist', filePath);
  }

  return filePath;
}
