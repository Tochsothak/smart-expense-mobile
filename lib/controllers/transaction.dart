import 'package:dio/dio.dart';
import 'package:smart_expense/models/result.dart';
import 'package:smart_expense/models/transaction.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/services/api.dart';
import 'package:smart_expense/services/api_routes.dart';
import 'package:smart_expense/services/transaction.dart';

class TransactionController {
  static Future<Result<TransactionModel>> create(
    String account,
    double amount,
    String category,
    String description,
    String type,
    String transactionDate,
    String notes,
  ) async {
    try {
      final response = await ApiService.post(ApiRoutes.transactionUrl, {
        'account': account,
        'amount': amount,
        'category': category,
        'description': description,
        'type': type,
        'transaction_date': transactionDate,
        'notes': notes,
      });
      final results = response.data['results'];

      final transaction = await TransactionService.create(
        results['transaction'],
      );
      print(transaction);
      return Result(
        isSuccess: true,
        message: response.data['message'],
        results: transaction,
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

  static Future<Result<List<TransactionModel>>> load() async {
    try {
      // Load accounts from hive
      final transactionBox = await TransactionService.getAll();
      if (transactionBox != null) {
        return Result(
          isSuccess: true,
          results: transactionBox,
          message: AppStrings.dataRetrievedSuccess,
        );
      }

      final response = await ApiService.get(ApiRoutes.transactionUrl, {});

      final results = response.data['results'];

      final transactions = await TransactionService.createTransactions(
        results['transactions'],
      );

      return Result(
        isSuccess: true,
        message: response.data['message'],
        results: transactions,
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

  static Future<Result<TransactionModel>?> get(Map<String, dynamic> id) async {
    try {
      // print("Getting account with ID: ${id['id']} from local storage");
      // Get Transaction by id from local storage
      final transactionBox = await TransactionService.getById(id['id']);
      if (transactionBox != null) {
        // print("AccountB found in local storage: $accountBox");
        return Result(
          isSuccess: true,
          results: transactionBox,
          message: AppStrings.dataRetrievedSuccess,
        );
      }
      //Get account from server
      final response = await ApiService.get(
        "${ApiRoutes.transactionUrl}/${id['id']}",
        id,
      );
      final result = response.data['results'];
      final transaction = result['transaction'];
      final transactionModel = TransactionModel.fromMap(transaction);
      // print("Account from server : $accountModel");
      return Result(
        isSuccess: true,
        results: transactionModel,
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

  static Future<Result<TransactionModel>> update(
    Map<String, dynamic> id,
    String category,
    String account,
    String type,
    double amount,
    String description,
    String notes,
    String transactionDate,
    int active,
  ) async {
    try {
      final response =
          await ApiService.patch("${ApiRoutes.transactionUrl}/${id['id']}", {
            'category': category,
            'account': account,
            'type': type,
            'amount': amount,
            'description': description,
            'notes': notes,
            'transaction_date': transactionDate,
            'active': active,
          }, id);
      final results = response.data['results'];
      final transactionModel = await TransactionService.create(
        results['transaction'],
      );
      // print("TransactionModel : ${transactionModel}");
      // print("Transaction : ${results['transaction']}");
      return Result(
        isSuccess: true,
        results: transactionModel,
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

  static Future<Result<TransactionModel>> delete(
    Map<String, dynamic> id,
  ) async {
    try {
      final response = await ApiService.delete(
        "${ApiRoutes.transactionUrl}/${id['id']}",
        id,
      );
      await TransactionService.deleteById(id['id']);
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
