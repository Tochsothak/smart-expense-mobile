class ApiRoutes {
  // 🔄 ONLY UPDATE THIS LINE when ngrok restarts
  static const String _ngrokUrl = 'https://a2a9b032db41.ngrok-free.app';

  // Base URL - automatically adds /api
  static const String baseUrl = '$_ngrokUrl/api';

  // Alternative configurations (comment/uncomment as needed)
  // static const String baseUrl = 'http://localhost:8000/api'; // Local development only
  // static const String baseUrl = 'https://smartexpense-api1.tochsothak.online/api'; // Hosted (when fixed)

  // Authentication Endpoints
  static const String registerUrl = '$baseUrl/register';
  static const String verify = '$baseUrl/verify';
  static const String logoutUrl = '$baseUrl/logout';
  static const String otpUrl = '$baseUrl/otp';
  static const String loginUrl = '$baseUrl/login';
  static const String resetOtpUrl = '$baseUrl/reset/otp';
  static const String resetPasswordUrl = '$baseUrl/reset/password';

  // Data Endpoints
  static const String currencyUrl = '$baseUrl/currency';
  static const String accountTypeUrl = '$baseUrl/account-type';
  static const String accountUrl = '$baseUrl/account';
  static const String categoryUrl = '$baseUrl/category';
  static const String transactionUrl = '$baseUrl/transactions';
  static const String rate = '$baseUrl/rate';

  // Profile Endpoints
  static const String profileUrl = '$baseUrl/profile';
  static const String profileImageUrl = '$baseUrl/profile/image';

  // Helper methods
  static void printCurrentConfig() {
    print('🔧 Current API Configuration:');
    print('   ngrok URL: $_ngrokUrl');
    print('   Base URL: $baseUrl');
    print('   Login URL: $loginUrl');
    print('   Currency URL: $currencyUrl');
  }

  // 📝 Instructions for updating (shows in console)
  static void printUpdateInstructions() {
    print('📝 To update ngrok URL:');
    print('1. Copy new ngrok URL from terminal (like https://abc123.ngrok.io)');
    print('2. Update _ngrokUrl in ApiRoutes.dart');
    print('3. Run: flutter build apk --debug && flutter install');
    print('4. Current URL: $_ngrokUrl');
  }

  // 🧪 Test URL for browser testing
  static String get testUrl => '$baseUrl/currency';
}
