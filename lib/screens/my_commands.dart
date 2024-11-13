import 'package:flutter/material.dart';
import 'command_creator.dart';

class MyCommandsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Commands'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CommandCreatorScreen()),
            );
          },
          child: Text('Create Command'),
        ),
      ),
    );
  }
}
