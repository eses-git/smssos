import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:smssos/fn/initialization.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'Your Privacy Policy Text Here...',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
               // await _initializeDatabase();
                await _setAgreementStatus(true);
                await init();
                print("iniiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiit");
                Navigator.pushNamed(context, '/');

              },
              child: Text('Agree and Understand'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _setAgreementStatus(false);
                SystemNavigator.pop();
              },
              child: Text('Not Agree Close App'),
            )
          ],
        ),
      ),
    );
  }


  Future<void> _setAgreementStatus(status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("status--------- $status");

    await prefs.setBool('agreedToPrivacyPolicy', status);
  }
}
