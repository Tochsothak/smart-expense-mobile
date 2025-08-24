import 'package:dio/dio.dart';
import 'package:smart_expense/models/currency.dart';
import 'package:smart_expense/models/result.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/services/api.dart';
import 'package:smart_expense/services/api_routes.dart';
import 'package:smart_expense/services/currency.dart';

class CurrencyController {
  static Future<Result<List<CurrencyModel>>> load() async {
    final currencyBoxList = await CurrencyService.getAll();
    if (currencyBoxList != null) {
      return Result(
        isSuccess: true,
        results: currencyBoxList,
        message: AppStrings.dataRetrievedSuccess,
      );
    }
    try {
      final response = await ApiService.get(ApiRoutes.currencyUrl, {});
      if (response.statusCode == 200) {
        final results = response.data['results'];
        final currencies = await CurrencyService.createCurrencies(
          results['currencies'],
        );
        return Result(
          isSuccess: true,
          message: response.data['message'],
          results: currencies,
        );
      } else {
        return Result(
          isSuccess: true,
          results: currencyBoxList,
          message: AppStrings.dataRetrievedSuccess,
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
