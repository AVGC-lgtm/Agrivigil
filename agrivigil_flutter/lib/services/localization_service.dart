import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _languageKey = 'selected_language';
  
  // Supported languages
  static const Map<String, LanguageModel> supportedLanguages = {
    'en': LanguageModel(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇬🇧',
    ),
    'hi': LanguageModel(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      flag: '🇮🇳',
    ),
    'ta': LanguageModel(
      code: 'ta',
      name: 'Tamil',
      nativeName: 'தமிழ்',
      flag: '🇮🇳',
    ),
    'te': LanguageModel(
      code: 'te',
      name: 'Telugu',
      nativeName: 'తెలుగు',
      flag: '🇮🇳',
    ),
    'kn': LanguageModel(
      code: 'kn',
      name: 'Kannada',
      nativeName: 'ಕನ್ನಡ',
      flag: '🇮🇳',
    ),
    'ml': LanguageModel(
      code: 'ml',
      name: 'Malayalam',
      nativeName: 'മലയാളം',
      flag: '🇮🇳',
    ),
    'mr': LanguageModel(
      code: 'mr',
      name: 'Marathi',
      nativeName: 'मराठी',
      flag: '🇮🇳',
    ),
    'gu': LanguageModel(
      code: 'gu',
      name: 'Gujarati',
      nativeName: 'ગુજરાતી',
      flag: '🇮🇳',
    ),
    'pa': LanguageModel(
      code: 'pa',
      name: 'Punjabi',
      nativeName: 'ਪੰਜਾਬੀ',
      flag: '🇮🇳',
    ),
    'bn': LanguageModel(
      code: 'bn',
      name: 'Bengali',
      nativeName: 'বাংলা',
      flag: '🇮🇳',
    ),
  };

  // Get current language
  static Future<String> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  // Set language
  static Future<bool> setLanguage(String languageCode) async {
    if (!supportedLanguages.containsKey(languageCode)) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_languageKey, languageCode);
  }

  // Get locale from language code
  static Locale getLocale(String languageCode) {
    return Locale(languageCode);
  }

  // Get current locale
  static Future<Locale> getCurrentLocale() async {
    final languageCode = await getCurrentLanguage();
    return getLocale(languageCode);
  }

  // Get supported locales
  static List<Locale> getSupportedLocales() {
    return supportedLanguages.keys.map((code) => Locale(code)).toList();
  }
}

// Language Model
class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

// App Localizations Delegate
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return LocalizationService.supportedLanguages.containsKey(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

// App Localizations
class AppLocalizations {
  final Locale locale;
  late Map<String, String> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  Future<bool> load() async {
    _localizedStrings = _translations[locale.languageCode] ?? _translations['en']!;
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Translations database
  static final Map<String, Map<String, String>> _translations = {
    'en': {
      // Common
      'app_name': 'AGRIVIGIL',
      'welcome': 'Welcome',
      'login': 'Login',
      'logout': 'Logout',
      'submit': 'Submit',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'search': 'Search',
      'filter': 'Filter',
      'export': 'Export',
      'back': 'Back',
      'next': 'Next',
      'previous': 'Previous',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'warning': 'Warning',
      'info': 'Information',
      'yes': 'Yes',
      'no': 'No',
      'confirm': 'Confirm',
      'close': 'Close',
      
      // Authentication
      'email': 'Email',
      'password': 'Password',
      'forgot_password': 'Forgot Password?',
      'sign_up': 'Sign Up',
      'sign_in': 'Sign In',
      'remember_me': 'Remember Me',
      
      // Dashboard
      'dashboard': 'Dashboard',
      'overview': 'Overview',
      'statistics': 'Statistics',
      'recent_activities': 'Recent Activities',
      'notifications': 'Notifications',
      
      // Inspections
      'inspections': 'Inspections',
      'new_inspection': 'New Inspection',
      'inspection_details': 'Inspection Details',
      'inspection_code': 'Inspection Code',
      'location': 'Location',
      'dealer_name': 'Dealer Name',
      'execution_date': 'Execution Date',
      'status': 'Status',
      'violation_found': 'Violation Found',
      'remarks': 'Remarks',
      
      // Seizures
      'seizures': 'Seizures',
      'new_seizure': 'New Seizure',
      'seizure_details': 'Seizure Details',
      'seizure_code': 'Seizure Code',
      'seizure_date': 'Seizure Date',
      'total_quantity': 'Total Quantity',
      'estimated_value': 'Estimated Value',
      'reason': 'Reason',
      
      // Lab Samples
      'lab_samples': 'Lab Samples',
      'new_sample': 'New Sample',
      'sample_details': 'Sample Details',
      'sample_code': 'Sample Code',
      'sample_type': 'Sample Type',
      'collection_date': 'Collection Date',
      'test_date': 'Test Date',
      'test_result': 'Test Result',
      'analyst_name': 'Analyst Name',
      
      // FIR Cases
      'fir_cases': 'FIR Cases',
      'new_fir': 'New FIR',
      'fir_details': 'FIR Details',
      'fir_number': 'FIR Number',
      'case_title': 'Case Title',
      'case_type': 'Case Type',
      'accused_name': 'Accused Name',
      'police_station': 'Police Station',
      'filed_date': 'Filed Date',
      
      // Forms
      'forms': 'Forms',
      'form_submissions': 'Form Submissions',
      'new_submission': 'New Submission',
      'farmer_name': 'Farmer Name',
      'farmer_contact': 'Farmer Contact',
      'submission_date': 'Submission Date',
      
      // Settings
      'settings': 'Settings',
      'profile': 'Profile',
      'language': 'Language',
      'theme': 'Theme',
      'notifications_settings': 'Notification Settings',
      'privacy': 'Privacy',
      'about': 'About',
      'help': 'Help',
      
      // Messages
      'login_success': 'Login successful',
      'login_failed': 'Login failed. Please check your credentials.',
      'logout_success': 'Logged out successfully',
      'save_success': 'Saved successfully',
      'delete_success': 'Deleted successfully',
      'update_success': 'Updated successfully',
      'operation_failed': 'Operation failed. Please try again.',
      'network_error': 'Network error. Please check your connection.',
      'permission_denied': 'Permission denied',
      'session_expired': 'Session expired. Please login again.',
    },
    
    'hi': {
      // Common
      'app_name': 'एग्रीविजिल',
      'welcome': 'स्वागत है',
      'login': 'लॉग इन',
      'logout': 'लॉग आउट',
      'submit': 'जमा करें',
      'cancel': 'रद्द करें',
      'save': 'सहेजें',
      'delete': 'हटाएं',
      'edit': 'संपादित करें',
      'search': 'खोजें',
      'filter': 'फ़िल्टर',
      'export': 'निर्यात',
      'back': 'वापस',
      'next': 'अगला',
      'previous': 'पिछला',
      'loading': 'लोड हो रहा है...',
      'error': 'त्रुटि',
      'success': 'सफलता',
      'warning': 'चेतावनी',
      'info': 'जानकारी',
      'yes': 'हाँ',
      'no': 'नहीं',
      'confirm': 'पुष्टि करें',
      'close': 'बंद करें',
      
      // Authentication
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'forgot_password': 'पासवर्ड भूल गए?',
      'sign_up': 'साइन अप',
      'sign_in': 'साइन इन',
      'remember_me': 'मुझे याद रखें',
      
      // Dashboard
      'dashboard': 'डैशबोर्ड',
      'overview': 'अवलोकन',
      'statistics': 'आंकड़े',
      'recent_activities': 'हाल की गतिविधियां',
      'notifications': 'सूचनाएं',
      
      // Inspections
      'inspections': 'निरीक्षण',
      'new_inspection': 'नया निरीक्षण',
      'inspection_details': 'निरीक्षण विवरण',
      'inspection_code': 'निरीक्षण कोड',
      'location': 'स्थान',
      'dealer_name': 'डीलर का नाम',
      'execution_date': 'निष्पादन तिथि',
      'status': 'स्थिति',
      'violation_found': 'उल्लंघन पाया गया',
      'remarks': 'टिप्पणियां',
      
      // Add more Hindi translations...
    },
    
    'ta': {
      // Common
      'app_name': 'அக்ரிவிஜில்',
      'welcome': 'வரவேற்கிறோம்',
      'login': 'உள்நுழை',
      'logout': 'வெளியேறு',
      'submit': 'சமர்ப்பி',
      'cancel': 'ரத்து',
      'save': 'சேமி',
      'delete': 'நீக்கு',
      'edit': 'திருத்து',
      'search': 'தேடு',
      'filter': 'வடிகட்டி',
      'export': 'ஏற்றுமதி',
      'back': 'பின்',
      'next': 'அடுத்து',
      'previous': 'முந்தைய',
      'loading': 'ஏற்றுகிறது...',
      'error': 'பிழை',
      'success': 'வெற்றி',
      'warning': 'எச்சரிக்கை',
      'info': 'தகவல்',
      'yes': 'ஆம்',
      'no': 'இல்லை',
      'confirm': 'உறுதிப்படுத்து',
      'close': 'மூடு',
      
      // Add more Tamil translations...
    },
    
    // Add translations for other languages (te, kn, ml, mr, gu, pa, bn)...
  };
}

// Language Selector Widget
class LanguageSelectorWidget extends StatefulWidget {
  final Function(String)? onLanguageChanged;
  
  const LanguageSelectorWidget({
    Key? key,
    this.onLanguageChanged,
  }) : super(key: key);

  @override
  State<LanguageSelectorWidget> createState() => _LanguageSelectorWidgetState();
}

class _LanguageSelectorWidgetState extends State<LanguageSelectorWidget> {
  String _currentLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final language = await LocalizationService.getCurrentLanguage();
    setState(() {
      _currentLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Row(
        children: [
          Text(
            LocalizationService.supportedLanguages[_currentLanguage]!.flag,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
      onSelected: (String languageCode) async {
        if (languageCode != _currentLanguage) {
          final success = await LocalizationService.setLanguage(languageCode);
          if (success) {
            setState(() {
              _currentLanguage = languageCode;
            });
            widget.onLanguageChanged?.call(languageCode);
          }
        }
      },
      itemBuilder: (BuildContext context) {
        return LocalizationService.supportedLanguages.entries.map((entry) {
          final language = entry.value;
          return PopupMenuItem<String>(
            value: entry.key,
            child: Row(
              children: [
                Text(
                  language.flag,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      language.nativeName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (_currentLanguage == entry.key) ...[
                  const Spacer(),
                  const Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 20,
                  ),
                ],
              ],
            ),
          );
        }).toList();
      },
    );
  }
}

// Extension for easy translation
extension TranslationExtension on BuildContext {
  String tr(String key) {
    return AppLocalizations.of(this)?.translate(key) ?? key;
  }
}
