import 'package:dio/dio.dart';
import 'package:smart_expense/models/account.dart';
import 'package:smart_expense/models/result.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/services/account.dart';
import 'package:smart_expense/services/api.dart';
import 'package:smart_expense/services/api_routes.dart';

class AccountController {
  static Future<Result<AccountModel>> create(
    double initialBalance,
    String name,
    String currency,
    String accountType,
  ) async {
    try {
      final response = await ApiService.post(ApiRoutes.accountUrl, {
        'account_type': accountType,
        'currency': currency,
        'name': name,
        'initial_balance': initialBalance,
      });
      final results = response.data['results'];

      final account = await AccountService.create(results['account']);

      return Result(
        isSuccess: true,
        message: response.data['message'],
        results: account,
      );
    } on DioException catch (e) {
      final message = ApiService.errorMessage(e);
      final errors = e.response?.data['errors'];
      return Result(isSuccess: false, message: message, errors: errors);
    } catch (e) {
      print(e);
      return Result(
        isSuccess: false,
        message: AppStrings.anErrorOccurredTryAgain,
      );
    }
  }

  static Future<Result<List<AccountModel>>> load() async {
    try {
      final response = await ApiService.get(ApiRoutes.accountUrl, {});
      final results = response.data['results'];
      final accounts = await AccountService.createAccounts(results['accounts']);
      return Result(
        isSuccess: true,
        message: response.data['message'],
        results: accounts,
      );
    } on DioException catch (e) {
      final errors = e.response?.data['errors'];
      final message = ApiService.errorMessage(e);
      return Result(isSuccess: false, message: message, errors: errors);
    } catch (e) {
      return Result(
        isSuccess: false,
        message: AppStrings.anErrorOccurredTryAgain,
      );
    }
  }
}
