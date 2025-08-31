// lib/controllers/profile.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:smart_expense/models/result.dart';
import 'package:smart_expense/models/user.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/services/api.dart';
import 'package:smart_expense/services/api_routes.dart';

class ProfileController {
  // Get user profile
  static Future<Result<UserModel>> getProfile() async {
    try {
      final response = await ApiService.get(ApiRoutes.profileUrl, {});

      if (response.statusCode == 200) {
        final results = response.data['results'];
        final user = UserModel.fromMap(results);

        return Result(
          isSuccess: true,
          message: response.data['message'],
          results: user,
        );
      } else {
        return Result(isSuccess: false, message: 'Failed to load profile');
      }
    } on DioException catch (e) {
      final message = ApiService.errorMessage(e);
      final errors = e.response?.data['errors'];
      return Result(isSuccess: false, message: message, errors: errors);
    } catch (e) {
      return Result(
        isSuccess: false,
        message: AppStrings.anErrorOccurredTryAgain,
      );
    }
  }

  // Update profile image
  static Future<Result<UserModel>> updateProfileImage(File imageFile) async {
    try {
      FormData formData = FormData.fromMap({
        'profile_image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await ApiService.postMultipart(
        ApiRoutes.profileImageUrl,
        formData,
      );

      if (response.statusCode == 200) {
        final results = response.data['results'];
        final user = UserModel.fromMap(results);

        return Result(
          isSuccess: true,
          message: response.data['message'],
          results: user,
        );
      } else {
        return Result(
          isSuccess: false,
          message: 'Failed to update profile image',
        );
      }
    } on DioException catch (e) {
      final message = ApiService.errorMessage(e);
      final errors = e.response?.data['errors'];
      return Result(isSuccess: false, message: message, errors: errors);
    } catch (e) {
      return Result(
        isSuccess: false,
        message: AppStrings.anErrorOccurredTryAgain,
      );
    }
  }

  // Delete profile image
  static Future<Result<UserModel>> deleteProfileImage() async {
    try {
      final response = await ApiService.delete(ApiRoutes.profileImageUrl, {});

      if (response.statusCode == 200) {
        final results = response.data['results'];
        final user = UserModel.fromMap(results);

        return Result(
          isSuccess: true,
          message: response.data['message'],
          results: user,
        );
      } else {
        return Result(
          isSuccess: false,
          message: 'Failed to delete profile image',
        );
      }
    } on DioException catch (e) {
      final message = ApiService.errorMessage(e);
      final errors = e.response?.data['errors'];
      return Result(isSuccess: false, message: message, errors: errors);
    } catch (e) {
      return Result(
        isSuccess: false,
        message: AppStrings.anErrorOccurredTryAgain,
      );
    }
  }
}
