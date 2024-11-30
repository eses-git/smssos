import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import '../classes/app_my_command.dart';
import '../classes/app_my_command_sample.dart';
import '../classes/data_base.dart';
import 'command_creator.dart';
import '../fn/to_train.dart';

class MyCommandsScreen extends StatefulWidget {
  @override
  _MyCommandsScreenState createState() => _MyCommandsScreenState();
}

class _MyCommandsScreenState extends State<MyCommandsScreen> {
  List<AppMyCommand> commands = [];
  FlutterSoundPlayer _player = FlutterSoundPlayer();
  String? selectedCommandId;
  String? playingSampleId;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _loadCommands();
  }

  Future<void> _initializePlayer() async {
    await _player.openPlayer();
  }

  Future<void> _loadCommands() async {
    final db = await AppDataBase().database;
    final List<Map<String, dynamic>> maps = await db.query('appMyCommand');
    setState(() {
      commands = maps.map((map) => AppMyCommand(
        appMyCommandId: map['appMyCommandId'],
        appAppId: map['app_appId'],
        name: map['name'],
        type: map['type'],
        status: map['status'],
        isInUse: map['isInUse'] == 1,
        trained: map['trained'] == 1,
        dateTimeCreation: map['dateTimeCreation'] != null ? DateTime.parse(map['dateTimeCreation']) : null,
        desc: map['desc'],
      )).toList();
    });
  }

  Future<List<AppMyCommandSample>> _loadSamples(String commandId) async {
    final db = await AppDataBase().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'appMyCommandSample',
      where: 'appMyCommandId = ?',
      whereArgs: [commandId],
    );
    return maps.map((map) => AppMyCommandSample(
      appMyCommandId: map['appMyCommandId'],
      appMyCommandSampleId: map['appMyCommandSampleId'],
      appAppId: map['app_appId'],
      path: map['path'],
      dateTimeCreation: map['dateTimeCreation'] != null ? DateTime.parse(map['dateTimeCreation']) : null,
    )).toList();
  }

  Future<void> _playSample(String sampleId, String path) async {
    if (await File(path).exists()) {
      setState(() {
        playingSampleId = sampleId; // Track which sample is currently playing
      });
      await _player.startPlayer(fromURI: path);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Recording not found or failed to save")),
      );
    }
  }

  Future<void> _stopSample() async {
    await _player.stopPlayer();
    setState(() {
      playingSampleId = null; // Reset the playing sample
    });
  }

  void _toggleCommandDetails(String commandId) {
    setState(() {
      // Toggle details visibility
      if (selectedCommandId == commandId) {
        selectedCommandId = null; // Hide details if already selected
      } else {
        selectedCommandId = commandId; // Show details for the new selection
      }
    });
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Commands'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CommandCreatorScreen()),
              );
            },
            child: Text('Create Command'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: commands.length,
              itemBuilder: (context, index) {
                final command = commands[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(command.name ?? 'Unnamed Command'),
                      subtitle: Text('Type: ${command.type ?? ''} | Status: ${command.status ?? ''} | In Use: ${command.isInUse}'),
                      onTap: () => _toggleCommandDetails(command.appMyCommandId),
                    ),
                    if (selectedCommandId == command.appMyCommandId)
                      _buildCommandDetails(command),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandDetails(AppMyCommand command) {
    return FutureBuilder<List<AppMyCommandSample>>(
      future: _loadSamples(command.appMyCommandId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("No samples available."),
          );
        }
        final samples = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Creation Date: ${command.dateTimeCreation}'),
              Text('Trained: ${command.trained}'),
              Text('Description: ${command.desc ?? 'No description'}'),
              SizedBox(height: 10),
              Text('Samples:', style: TextStyle(fontWeight: FontWeight.bold)),

              // Add Train Button
              ElevatedButton(
                onPressed: () async {
                  await trainMe(command.appMyCommandId); // Call trainMe
                  setState(() {
                    command.trained = true; // Update trained status (if needed)
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Command trained successfully!")),
                  );
                },
                child: Text("Train"), // Always show "Train"
              ),


              // Display List of Samples
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: samples.length,
                itemBuilder: (context, index) {
                  final sample = samples[index];
                  return ListTile(
                    title: Text(sample.fileName ?? 'Sample ${index + 1}'),
                    subtitle: Text('Created on: ${sample.dateTimeCreation}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.play_arrow),
                          onPressed: playingSampleId == sample.appMyCommandSampleId
                              ? null
                              : () => _playSample(sample.appMyCommandSampleId, sample.path!),
                        ),
                        IconButton(
                          icon: Icon(Icons.stop),
                          onPressed: playingSampleId == sample.appMyCommandSampleId ? _stopSample : null,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
