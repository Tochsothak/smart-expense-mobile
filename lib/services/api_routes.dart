class ApiRoutes {
  // Base Url
  static const String baseUrl = 'http://192.168.78.180:8000/api';

  // Endpoint
  static const String registerUrl = '$baseUrl/register';
  static const String verify = '$baseUrl/verify';
  static const String logoutUrl = '$baseUrl/logout';
  static const String otpUrl = '$baseUrl/otp';
  static const String loginUrl = '$baseUrl/login';
  static const String resetOtpUrl = '$baseUrl/reset/otp';
  static const String resetPasswordUrl = '$baseUrl/reset/password';

  static const String currencyUrl = '$baseUrl/currency';

  static const String accountTypeUrl = '$baseUrl/account-type';

  static const String accountUrl = '$baseUrl/account';

  static const String categoryUrl = '$baseUrl/category';

  static const String transactionUrl = '$baseUrl/transaction';
}
