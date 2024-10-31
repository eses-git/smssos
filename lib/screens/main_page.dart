import 'package:flutter/material.dart';
//import 'package:google_assistant_caregiver/google_assistant_caregiver.dart'; // Import your plugin
import 'settings.dart';
import 'personal_data.dart';
import 'contacts.dart';

class CustomFloatingActionButton extends FloatingActionButton {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final double elevation;

  CustomFloatingActionButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.elevation,
    required Widget child,
  }) : super(
    onPressed: onPressed,
    backgroundColor: backgroundColor,
    elevation: elevation,
    child: child,
  );
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isOn = false;  // Default state is "off"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
      ),
      body: Center(
        child: Text('Welcome to my app!'),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Turn On/Off Button
          FloatingActionButton.extended(
            onPressed: () async {
              setState(() {
                _isOn = !_isOn;  // Toggle the state
              });

              if (_isOn) {
            //    await GoogleAssistantCaregiver.startListening("Hey Assistant");  // Call startListening from plugin
              } else {
            //    await GoogleAssistantCaregiver.closeListening();  // Call closeListening from plugin
              }
            },
            backgroundColor: _isOn ? Colors.green : Colors.red,  // Green when on, red when off
            icon: Icon(_isOn ? Icons.power_off : Icons.power),
            label: Text(_isOn ? 'Turn Off' : 'Turn On'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),  // Rounded button
            ),
            elevation: 10.0,
          ),
          SizedBox(height: 16),

          // Settings Button
          CustomFloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
            backgroundColor: Colors.blue,
            elevation: 9.0,
            child: Icon(Icons.settings),
          ),
          SizedBox(height: 16),

          // Personal Data Button
          CustomFloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PersonalDataScreen()));
            },
            backgroundColor: Colors.green,
            elevation: 9.0,
            child: Icon(Icons.person),
          ),
          SizedBox(height: 16),

          // Contacts Button
          CustomFloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ContactsScreen()));
            },
            backgroundColor: Colors.orange,
            elevation: 9.0,
            child: Icon(Icons.contacts),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

void main() {
  runApp(MaterialApp(home: MainPage()));
}
