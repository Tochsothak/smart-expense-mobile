import 'package:dio/dio.dart';
import 'package:smart_expense/controllers/account_type.dart';
import 'package:smart_expense/models/account.dart';
import 'package:smart_expense/models/result.dart';
import 'package:smart_expense/resources/app_route.dart';

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
      // print(e);
      return Result(
        isSuccess: false,
        message: AppStrings.anErrorOccurredTryAgain,
      );
    }
  }

  static Future<Result<List<AccountModel>>> load() async {
    try {
      //Load accounts from hive
      final accountsBox = await AccountService.getAll();
      if (accountsBox != null) {
        return Result(
          isSuccess: true,
          results: accountsBox,
          message: AppStrings.dataRetrievedSuccess,
        );
      }

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

  static Future<Result<AccountModel>?> get(Map<String, dynamic> id) async {
    try {
      // print("Getting account with ID: ${id['id']} from local storage");
      // Get Account by id from local storage
      final accountBox = await AccountService.getById(id['id']);
      if (accountBox != null) {
        // print("AccountB found in local storage: $accountBox");
        return Result(
          isSuccess: true,
          results: accountBox,
          message: AppStrings.dataRetrievedSuccess,
        );
      }
      //Get account from server
      final response = await ApiService.get(
        "${ApiRoutes.accountUrl}/${id['id']}",
        id,
      );
      final result = response.data['results'];
      final account = result['account'];
      final accountModel = AccountModel.fromMap(account);
      // print("Account from server : $accountModel");
      return Result(
        isSuccess: true,
        results: accountModel,
        message: response.data['message'],
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

  static Future<Result<AccountModel>> update(
    Map<String, dynamic> id,
    String accountType,
    String name,
    double initialBalance,
    int active,
  ) async {
    try {
      final response =
          await ApiService.patch("${ApiRoutes.accountUrl}/${id['id']}", {
            'account_type': accountType,
            'name': name,
            'initial_balance': initialBalance,
            'active': active,
          }, id);
      final results = response.data['results'];
      final accountModel = await AccountService.create(results['account']);
      return Result(
        isSuccess: true,
        results: accountModel,
        message: response.data['message'],
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

  static Future<Result> delete(Map<String, dynamic> id) async {
    try {
      final response = await ApiService.delete(
        "${ApiRoutes.accountUrl}/${id['id']}",
        id,
      );
      await AccountService.deleteById(id['id']);
      final message = response.data['message'];
      return Result(isSuccess: true, message: message);
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
