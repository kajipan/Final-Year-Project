// lib/translations.dart

class AppTranslations {
  static Map<String, Map<String, String>> translations = {
    'en': {
      'appTitle': 'MechNow',
      'welcomeBack': 'Welcome Back!',
      'login': 'Login',
      'register': 'Register',
      'requestMechanic': 'Request Mechanic',
      'selectIssue': 'Select Your Vehicle Issue',
      'battery': 'Battery',
      'tyre': 'Tyre',
      'engine': 'Engine',
      'mechanicOnTheWay': 'Mechanic is on the way!',
      'nearbyMechanics': 'Nearby Mechanics',
      'incomingRequests': 'Incoming Requests',
    },
    'ta': {
      'appTitle': 'மெக்நவ்',
      'welcomeBack': 'வரவேற்கிறோம்!',
      'login': 'உள்நுழைவு',
      'register': 'பதிவு செய்',
      'requestMechanic': 'மெக்கானிக் கேள்',
      'selectIssue': 'உங்கள் வாகன பிரச்சனையை தேர்வு செய்க',
      'battery': 'பேட்டரி',
      'tyre': 'டயர்',
      'engine': 'எஞ்சின்',
      'mechanicOnTheWay': 'மெக்கானிக் வந்து கொண்டிருக்கிறார்!',
      'nearbyMechanics': 'அருகில் உள்ள மெக்கானிக்கள்',
      'incomingRequests': 'உள்வரும் கோரிக்கைகள்',
    },
    'si': {
      'appTitle': 'මෙක්නව්',
      'welcomeBack': 'ආයුබෝවන්!',
      'login': 'පිවිසෙන්න',
      'register': 'ලියාපදිංචි වන්න',
      'requestMechanic': 'යාන්ත්‍රිකවරයෙකු ඉල්ලන්න',
      'selectIssue': 'ඔබේ වාහන ගැටලුව තෝරන්න',
      'battery': 'බැටරිය',
      'tyre': 'ටයරය',
      'engine': 'එන්ජිම',
      'mechanicOnTheWay': 'යාන්ත්‍රිකවරයා මාර්ගයේය!',
      'nearbyMechanics': 'ආසන්න යාන්ත්‍රිකවරුන්',
      'incomingRequests': 'එන ඉල්ලීම්',
    },
  };

  static String getText(String key, String langCode) {
    return translations[langCode]?[key] ?? translations['en']![key]!;
  }
}