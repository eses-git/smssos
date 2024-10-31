/*import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_localizations.dart';
import 'privacy_policy_screen.dart';
import 'main_page.dart'; // Ensure this import points to the correct location of MainPage

class LanguageSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('lang iniiiiiiiiiiiiiiiit');
    return Scaffold(
      appBar: AppBar(title: Text('Select Language')),
      body: ListView.builder(
        itemCount: AppLocalizations.supportedLanguages.length,
        itemBuilder: (context, index) {
          String languageCode = AppLocalizations.supportedLanguages[index];
          return ListTile(
            title: Text(AppLocalizations.getLanguageName(languageCode)),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();

              await prefs.setString('selectedLanguage', languageCode);
              // Directly check the agreement status after setting the language
              bool agreedToPrivacyPolicy = prefs.getBool('agreedToPrivacyPolicy') ?? false;
              if (!agreedToPrivacyPolicy) {
                // Navigate to PrivacyPolicyScreen if the agreement status is false

                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => PrivacyPolicyScreen()));
              } else {
                // Navigate to MainPage if the agreement status is true

                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainPage()));
              }
            },
          );
        },
      ),
    );
  }
}*/