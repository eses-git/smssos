import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../classes/app_my_command.dart';
import '../classes/app_my_command_sample.dart';
import '../classes/data_base.dart';

class CommandCreatorScreen extends StatefulWidget {
  @override
  _CommandCreatorScreenState createState() => _CommandCreatorScreenState();
}

class _CommandCreatorScreenState extends State<CommandCreatorScreen> {
  AppMyCommand? commandModel;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  List<AppMyCommandSample> samples = [];
  List<bool> isRecordingList = [];
  List<Duration> recordingDurations = []; // Stores the duration of each recording
  int sampleCounter = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _initializePlayer();
    _initializeModel();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
    _recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  Future<void> _initializePlayer() async {
    await _player.openPlayer();
  }

  Future<void> _initializeModel() async {
    final prefs = await SharedPreferences.getInstance();
    final appId = prefs.getString('appId') ?? '';
    final commandId = Uuid().v4();
    final directory = await getApplicationDocumentsDirectory();
    final modelPath = '${directory.path}/commands/$commandId';
    final samplePath = '$modelPath/samples';

    await Directory(modelPath).create(recursive: true);
    await Directory(samplePath).create();

    setState(() {
      commandModel = AppMyCommand(
        appMyCommandId: commandId,
        appAppId: appId,
        modelPath: modelPath,
        samplePath: samplePath,
        status: 'DRAFT',
        isInUse: false,
        trained: false,
        dateTimeCreation: DateTime.now(),
      );
    });
  }

  Future<void> _startRecording(int index) async {
    if (isRecordingList[index]) return;

    final sampleFilePath = '${commandModel!.samplePath}/sample$sampleCounter.aac';
    await _recorder.startRecorder(
      toFile: sampleFilePath,
      codec: Codec.aacADTS,
    );

    setState(() {
      isRecordingList[index] = true;
      recordingDurations[index] = Duration.zero;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        recordingDurations[index] = recordingDurations[index] + Duration(seconds: 1);
      });
    });

    // Stop recording after 10 seconds automatically
    Timer(Duration(seconds: 10), () => _stopRecording(index));
  }

  Future<void> _stopRecording(int index) async {
    if (!isRecordingList[index]) return;

    final path = await _recorder.stopRecorder();
    _timer?.cancel();

    setState(() {
      isRecordingList[index] = false;
      samples[index] = samples[index].copyWith(path: path, dateTimeCreation: DateTime.now());
      // Save the final duration
      recordingDurations[index] = Duration(seconds: recordingDurations[index].inSeconds);
    });
  }

  Future<void> _playSample(String path) async {
    if (await File(path).exists()) {
      await _player.startPlayer(
        fromURI: path,
        codec: Codec.aacADTS,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Recording not found or failed to save")),
      );
    }
  }

  void _addSampleRow() {
    if (commandModel == null) return;
    setState(() {
      final sampleId = Uuid().v4();
      samples.add(AppMyCommandSample(
        appMyCommandId: commandModel!.appMyCommandId,
        appMyCommandSampleId: sampleId,
        appAppId: commandModel!.appAppId,
        path: '${commandModel!.samplePath}/sample$sampleCounter.aac',
        dateTimeCreation: DateTime.now(),
      ));
      isRecordingList.add(false);
      recordingDurations.add(Duration.zero); // Initialize duration for each new sample
      sampleCounter++;
    });
  }
  Future<void> _saveData() async {
    if (commandModel == null) return;

    // Validation check
    if (samples.length < 5 || recordingDurations.any((duration) => duration.inSeconds < 4)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please provide at least 5 samples, each with a minimum duration of 4 seconds.")),
      );
      return;
    }

    try {
      final db = await AppDataBase().database;
      await AppMyCommand.insert(commandModel!, db);

      for (var sample in samples) {
        await AppMyCommandSample.insert(sample, db);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data saved successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving data: $e")),
      );
    }
  }

  Future<void> _saveAndTrain() async {
    // Validation check
    if (samples.length < 5 || recordingDurations.any((duration) => duration.inSeconds < 4)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please provide at least 5 samples, each with a minimum duration of 4 seconds.")),
      );
      return;
    }

    setState(() {
      commandModel = commandModel!.copyWith(
        status: 'COMPLETE',
        trained: true,
        lastUpdate: DateTime.now(),
        sampleCount: samples.length,
      );
    });

    await _saveData();
    Navigator.pushNamed(context, '/train_me', arguments: commandModel!.appMyCommandId);
  }


  void _deleteSample(int index) async {
    final sample = samples[index];
    final file = File(sample.path!);
    if (await file.exists()) {
      await file.delete();
    }
    setState(() {
      samples.removeAt(index);
      isRecordingList.removeAt(index);
      recordingDurations.removeAt(index); // Remove the duration for the deleted sample
    });
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Command'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              maxLength: 200,
              decoration: InputDecoration(labelText: 'Name'),
              onChanged: (value) => commandModel = commandModel!.copyWith(name: value),
            ),
            TextFormField(
              controller: _descController,
              maxLength: 400,
              decoration: InputDecoration(labelText: 'Description'),
              onChanged: (value) => commandModel = commandModel!.copyWith(desc: value),
            ),
            ElevatedButton(
              onPressed: _addSampleRow,
              child: Text('Add Sample'),
            ),
            ..._buildSampleList(),
            ElevatedButton(
              onPressed: _saveData,
              child: Text('Save and Exit'),
            ),
            ElevatedButton(
              onPressed: _saveAndTrain,
              child: Text('Save and Train'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSampleList() {
    return List<Widget>.generate(samples.length, (index) {
      final duration = recordingDurations[index];
      final durationText = duration.inSeconds > 0
          ? '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}'
          : '00:00';

      return Row(
        children: [
          Text('Sample ${index + 1} ($durationText)'),
          IconButton(
            icon: Icon(isRecordingList[index] ? Icons.stop : Icons.mic),
            onPressed: isRecordingList[index]
                ? () => _stopRecording(index)
                : () => _startRecording(index),
          ),
          if (samples[index].path != null)
            IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: () => _playSample(samples[index].path!),
            ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deleteSample(index),
          ),
        ],
      );
    });
  }
}
