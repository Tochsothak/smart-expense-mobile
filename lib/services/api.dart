import 'package:dio/dio.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/services/auth.dart';

class ApiService {
  static final dio = Dio();
  // post
  static Future<Response> post(String url, Map<String, dynamic> body) async {
    final user = await AuthService.get();
    final response = await dio.post(
      url,
      data: body,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${user?.token}',
        },
      ),
    );

    return response;
  }

  // get

  static Future<Response> get(String url, Map<String, dynamic> params) async {
    final user = await AuthService.get();
    final response = dio.get(
      url,
      queryParameters: params,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${user?.token}',
        },
      ),
    );
    return response;
  }

  static String errorMessage(DioException dioException) {
    final internetErrors = [
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ];
    if (internetErrors.contains(dioException.type)) {
      return AppStrings.noInternetAccess;
    }
    final message =
        dioException.response?.data['message'] ??
        AppStrings.anErrorOccurredTryAgain;
    return message;
  }
}
