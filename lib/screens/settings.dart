import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'main_page.dart';
import '../classes/settings.dart';
import '../fn/app.dart';
import '../fn/location.dart';
import '../fn/recording.dart';
import '../fn/sms.dart';
import '../fn/telegram.dart';
import '../fn/voice_command.dart';
import '../fn/whatsapp.dart';
import 'command.dart'; // Import the commands screen

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Settings settings = Settings();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isLocation = false;
  bool _isRecordingPermission = false;
  bool _viaWhatsApp = false;
  bool _viaSMS = false;
  bool _viaTelegram = false;
  bool _viaAPP = false;
  bool _isListening = false;
  String _commandText = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await settings.loadSettings();
    setState(() {
      _isLocation = settings.isLocationPermission;
      _isRecordingPermission = settings.isRecordingPermission;
      _viaWhatsApp = settings.viaWhatsApp;
      _viaSMS = settings.viaSMS;
      _viaTelegram = settings.viaTelegram;
      _viaAPP = settings.viaAPP;
    });
  }

  void _handleCommand(String command) {
    if (command.contains('location')) {
      _toggleSetting(() => _isLocation = !_isLocation, (newValue) => allowLocation(context, newValue));
    } else if (command.contains('recording')) {
      _toggleSetting(() => _isRecordingPermission = !_isRecordingPermission, (newValue) => allowVoiceRecording(context, newValue));
    } else if (command.contains('WhatsApp')) {
      _toggleSetting(() => _viaWhatsApp = !_viaWhatsApp, (newValue) => allowWhatsApp(newValue));
    } else if (command.contains('SMS')) {
      _toggleSetting(() => _viaSMS = !_viaSMS, (newValue) => allowSMS(newValue));
    } else if (command.contains('Telegram')) {
      _toggleSetting(() => _viaTelegram = !_viaTelegram, (newValue) => allowTelegram(newValue));
    } else if (command.contains('app')) {
      _toggleSetting(() => _viaAPP = !_viaAPP, (newValue) => allowAPP(newValue));
    }
  }

  // Corrected _toggleSetting function
  void _toggleSetting(VoidCallback toggle, Future<void> Function(bool) action) {
    setState(toggle);
    bool newValue = _getToggleValue(); // Get the current state after toggling
    action(newValue); // Pass the new value to the action function
  }

  // Helper function to return the current toggle value based on the setting
  bool _getToggleValue() {
    return false; // Default case for example (adjust as per setting)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainPage()),
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'My Awesome App Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildSwitchListTile(
              'Allow location',
              _isLocation,
                  (newValue) async {
                setState(() {
                  _isLocation = newValue;
                });
                await allowLocation(context, newValue);
              },
            ),
            _buildSwitchListTile(
              'Allow recording',
              _isRecordingPermission,
                  (newValue) async {
                setState(() {
                  _isRecordingPermission = newValue;
                });
                await allowVoiceRecording(context, newValue);
              },
            ),
            _buildSwitchListTile(
              'Message via WhatsApp?',
              _viaWhatsApp,
                  (newValue) async {
                setState(() {
                  _viaWhatsApp = newValue;
                });
                await allowWhatsApp(newValue);
              },
            ),
            _buildSwitchListTile(
              'Message via SMS?',
              _viaSMS,
                  (newValue) async {
                setState(() {
                  _viaSMS = newValue;
                });
                await allowSMS(newValue);
              },
            ),
            _buildSwitchListTile(
              'Message via Telegram?',
              _viaTelegram,
                  (newValue) async {
                setState(() {
                  _viaTelegram = newValue;
                });
                await allowTelegram(newValue);
              },
            ),
            _buildSwitchListTile(
              'Message via Application?',
              _viaAPP,
                  (newValue) async {
                setState(() {
                  _viaAPP = newValue;
                });
                await allowAPP(newValue);
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CommandsScreen()),
                );
              },
              child: Text('Go to Commands'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchListTile(String title, bool value, Future<void> Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: (newValue) async {
        setState(() {
          value = newValue;
        });
        await onChanged(newValue);
      },
    );
  }
}
