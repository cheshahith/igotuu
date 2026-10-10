/// Application constants
class AppConstants {
  AppConstants._();

  static const String appName = 'igotuu';
  static const String prefSavedAddress = 'saved_user_address';
  static const String defaultAddress = '742 Evergreen Terrace, Springfield';

  // Supported speech recognition languages
  static const List<Map<String, String>> supportedLanguages = [
    {'name': 'English', 'code': 'en_US'},
    {'name': 'Tamil', 'code': 'ta_IN'},
    {'name': 'Hindi', 'code': 'hi_IN'},
  ];
}
