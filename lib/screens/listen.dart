import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:offline_listening/offline_listening.dart';

class ListeningScreen extends StatefulWidget {
  @override
  _ListeningScreenState createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  bool isListening = false;

  Future<String> getModelPath(String fileName) async {
    try {
      // Load the asset file from the app's assets
      final byteData = await rootBundle.load('assets/commands/$fileName');

      // Get the app's temporary directory
      final tempDir = await getTemporaryDirectory();

      // Define the temporary file path
      final tempFilePath = '${tempDir.path}/$fileName';
      final tempFile = File(tempFilePath);

      // Write the asset data to the temporary file
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());

      // Log the file path
      print("Model file path: $tempFilePath");

      // Verify the file exists
      if (!tempFile.existsSync()) {
        throw FileSystemException('Model file does not exist', tempFilePath);
      }

      return tempFilePath;
    } catch (e) {
      throw FileSystemException('Failed to load model file: $e');
    }
  }

  Future<void> startListening() async {
    try {
      // Get the path to the wake word model
      final modelPath = await getModelPath('wake_word_model.tflite');

      // Start listening using the model path
      await OfflineListening.startListening(
        modelPaths: [modelPath],
      );

      // Set the state to listening
      setState(() {
        isListening = true;
      });

      print("Listening started with model: $modelPath");

      // Verify the model is loaded
      final isModelValid = await OfflineListening.isModelLoaded(modelPath);
      if (isModelValid) {
        print("Model loaded successfully: $modelPath");
      } else {
        print("Model failed to load: $modelPath");
      }
    } catch (e) {
      print("Error starting listening: $e");
    }
  }

  Future<void> stopListening() async {
    try {
      // Stop listening
      await OfflineListening.stopListening();
      setState(() {
        isListening = false;
      });
      print("Listening stopped");
    } catch (e) {
      print("Error stopping listening: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wake Word Listening"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isListening ? null : startListening,
              child: Text("Start Listening"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isListening ? stopListening : null,
              child: Text("Stop Listening"),
            ),
            SizedBox(height: 20),
            Text(
              isListening ? "Listening for wake words..." : "Press Start to begin listening",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
