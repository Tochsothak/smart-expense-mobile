import 'package:dio/dio.dart';
import 'package:smart_expense/models/category.dart';
import 'package:smart_expense/models/result.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/services/api.dart';
import 'package:smart_expense/services/api_routes.dart';
import 'package:smart_expense/services/category.dart';

class CategoryController {
  static Future<Result<List<CategoryModel>>> load() async {
    try {
      final categoryBoxList = await CategoryService.getAll();
      if (categoryBoxList != null) {
        return Result(
          isSuccess: true,
          results: categoryBoxList,
          message: AppStrings.dataRetrievedSuccess,
        );
      }
      final response = await ApiService.get(ApiRoutes.categoryUrl, {});
      final results = response.data['results'];
      final categories = await CategoryService.createCategories(
        results['categories'],
      );

      print("Categories : ${categories[1]}");
      print("Message : ${response.data['message']}");

      return Result(
        isSuccess: true,
        message: response.data['message'],
        results: categories,
      );
    } on DioException catch (e) {
      final message = ApiService.errorMessage(e);
      final errors = e.response?.data['errors'];

      return Result(isSuccess: false, message: message, errors: errors);
    } catch (e) {
      print("Category : $e");
      return Result(
        isSuccess: false,
        message: AppStrings.anErrorOccurredTryAgain,
      );
    }
  }
}
