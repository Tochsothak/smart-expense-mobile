import 'package:dio/dio.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/services/auth.dart';
import 'dart:io';

class ApiService {
  static final dio = Dio();

  // Initialize Dio with default configurations
  static void initialize() {
    dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    );

    // Add interceptors for logging (optional)
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );
  }

  // Helper method to get common headers
  static Future<Map<String, String>> _getHeaders({
    bool isMultipart = false,
  }) async {
    final user = await AuthService.get();

    Map<String, String> headers = {};

    // Add authorization header if user token exists
    if (user?.token != null) {
      headers['Authorization'] = 'Bearer ${user!.token}';
    }

    if (!isMultipart) {
      headers['Accept'] = 'application/json';
      headers['Content-Type'] = 'application/json';
    } else {
      headers['Accept'] = 'application/json';
      // Don't set Content-Type for multipart, let Dio handle it
    }

    return headers;
  }

  // Original post method
  static Future<Response> post(String url, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await dio.post(
        url,
        data: body,
        options: Options(headers: headers),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Multipart post method for file uploads
  static Future<Response> postMultipart(
    String url,
    FormData formData, {
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final headers = await _getHeaders(isMultipart: true);
      // Add any additional headers
      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }
      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: headers,
          // Set longer timeout for file uploads
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
        onSendProgress: (sent, total) {
          // Optional: You can add upload progress callback here
          if (total != -1) {
            double progress = sent / total;
            print('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
          }
        },
      );
      print(
        'POST Multipart Response: ${response.statusCode} - ${response.data}',
      );
      return response;
    } catch (e) {
      print('POST Multipart Error: $e');
      rethrow;
    }
  }

  // Original get method
  static Future<Response> get(String url, Map<String, dynamic> params) async {
    try {
      final headers = await _getHeaders();
      final response = await dio.get(
        url,
        queryParameters: params,
        options: Options(headers: headers),
      );

      print('GET Response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('GET Error: $e');
      rethrow;
    }
  }

  // Original patch method
  static Future<Response> patch(
    String url,
    Map<String, dynamic> body,
    Map<String, dynamic> params,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await dio.patch(
        url,
        queryParameters: params,
        data: body,
        options: Options(headers: headers),
      );

      print('PATCH Response: ${response.statusCode} - ${response.data}');
      return response;
    } catch (e) {
      print('PATCH Error: $e');
      rethrow;
    }
  }

  // New multipart patch method for file uploads with updates
  static Future<Response> patchMultipart(
    String url,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final headers = await _getHeaders(isMultipart: true);

      // Add any additional headers
      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }
      print('PATCH Multipart URL: $url');
      print('PATCH Multipart Headers: $headers');

      final response = await dio.patch(
        url,
        queryParameters: queryParameters,
        data: formData,
        options: Options(
          headers: headers,
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
        onSendProgress: (sent, total) {
          if (total != -1) {
            double progress = sent / total;
            print('Update progress: ${(progress * 100).toStringAsFixed(1)}%');
          }
        },
      );

      print(
        'PATCH Multipart Response: ${response.statusCode} - ${response.data}',
      );
      return response;
    } catch (e) {
      print('PATCH Multipart Error: $e');
      rethrow;
    }
  }

  // Original delete method
  static Future<Response> delete(
    String url,
    Map<String, dynamic> params,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await dio.delete(
        url,
        queryParameters: params,
        options: Options(headers: headers),
      );

      print('DELETE Response: ${response.statusCode} - ${response.data}');
      return response;
    } catch (e) {
      print('DELETE Error: $e');
      rethrow;
    }
  }

  //Method for downloading files
  static Future<Response> downloadFile(
    String url,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final headers = await _getHeaders();

      final response = await dio.download(
        url,
        savePath,
        queryParameters: queryParameters,
        options: Options(
          headers: headers,
          receiveTimeout: const Duration(minutes: 10),
        ),
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } catch (e) {
      print('Download Error: $e');
      rethrow;
    }
  }

  // Enhanced error message method
  static String errorMessage(DioException dioException) {
    print('DioException Type: ${dioException.type}');
    print('DioException Message: ${dioException.message}');
    print('DioException Response: ${dioException.response?.data}');
    print('DioException Status Code: ${dioException.response?.statusCode}');

    final internetErrors = [
      DioExceptionType.connectionError,
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ];

    if (internetErrors.contains(dioException.type)) {
      return AppStrings.noInternetAccess;
    }

    // Handle specific HTTP status codes
    if (dioException.response != null) {
      final statusCode = dioException.response!.statusCode;
      final responseData = dioException.response!.data;

      switch (statusCode) {
        case 400:
          return responseData['message'] ?? 'Bad request';
        case 401:
          return 'Unauthorized. Please login again.';
        case 403:
          return 'Access forbidden';
        case 404:
          return 'Resource not found';
        case 413:
          return 'File too large. Please select a smaller file.';
        case 422:
          // Validation errors
          if (responseData != null && responseData['errors'] != null) {
            final errors = responseData['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              return firstError.first.toString();
            }
          }
          return responseData?['message'] ?? 'Validation failed';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return responseData?['message'] ?? AppStrings.anErrorOccurredTryAgain;
      }
    }

    // Handle other Dio exceptions
    switch (dioException.type) {
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.badResponse:
        return 'Invalid response from server';
      case DioExceptionType.unknown:
        return 'Network error occurred';
      default:
        return AppStrings.anErrorOccurredTryAgain;
    }
  }

  // Helper method to create FormData from Map
  static FormData createFormData(Map<String, dynamic> data) {
    return FormData.fromMap(data);
  }

  // Helper method to validate file before upload
  static bool isValidFile(
    String filePath, {
    List<String>? allowedExtensions,
    int? maxSizeInMB,
  }) {
    try {
      final file = File(filePath);

      // Check if file exists
      if (!file.existsSync()) {
        return false;
      }

      // Check file extension
      if (allowedExtensions != null) {
        final extension = filePath.split('.').last.toLowerCase();
        if (!allowedExtensions.contains(extension)) {
          return false;
        }
      }

      // Check file size
      if (maxSizeInMB != null) {
        final fileSizeInMB = file.lengthSync() / (1024 * 1024);
        if (fileSizeInMB > maxSizeInMB) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Helper method to get file size in human readable format
  static String getFileSizeString(int bytes) {
    if (bytes <= 0) return "0 B";

    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    int i = (bytes.bitLength - 1) ~/ 10;

    if (i >= suffixes.length) i = suffixes.length - 1;

    return '${(bytes / (1 << (i * 10))).toStringAsFixed(1)} ${suffixes[i]}';
  }

  // Method to cancel all ongoing requests
  static void cancelAllRequests() {
    dio.close();
  }

  // Method to check network connectivity
  static Future<bool> checkConnectivity() async {
    try {
      final response = await dio.get(
        'https://www.google.com',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
