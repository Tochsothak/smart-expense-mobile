class ApiRoutes {
  // Base Url
  static const String baseUrl = 'http://192.168.189.180:8000/api';

  // Endpoind
  static const String registerUrl = '$baseUrl/register';
  static const String verify = '$baseUrl/verify';
  static const String logoutUrl = '$baseUrl/logout';
  static const String otpUrl = '$baseUrl/otp';
  static const String loginUrl = '$baseUrl/login';
  static const String resetOtpUrl = '$baseUrl/reset/otp';
  static const String resetPasswordUrl = '$baseUrl/reset/password';
}
