// lib/app_localizations.dart

class AppLocalizations {
  static const List<String> supportedLanguages = ['en', 'es', 'fr']; // Example languages: English, Spanish, French

  static String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      default:
        return 'English';
    }
  }
}