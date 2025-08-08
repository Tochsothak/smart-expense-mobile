import 'package:dio/dio.dart';
import 'package:smart_expense/models/account_type.dart';
import 'package:smart_expense/models/result.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/services/account_type.dart';
import 'package:smart_expense/services/api.dart';
import 'package:smart_expense/services/api_routes.dart';

class AccountTypeController {
  static Future<Result<List<AccountTypeModel>>> load() async {
    try {
      final accountTypeBoxList = await AccountTypeService.getAll();
      if (accountTypeBoxList != null) {
        return Result(
          isSuccess: true,
          results: accountTypeBoxList,
          message: AppStrings.dataRetrievedSuccess,
        );
      }

      final response = await ApiService.get(ApiRoutes.accountTypeUrl, {});
      final results = response.data['results'];
      final accountTypes = await AccountTypeService.createAccountTypes(
        results['account_types'],
      );
      return Result(
        isSuccess: true,
        message: response.data['message'],
        results: accountTypes,
      );
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
