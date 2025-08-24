import 'package:dio/dio.dart';
import 'package:smart_expense/models/exchange_rate.dart';
import 'package:smart_expense/models/result.dart';
import 'package:smart_expense/resources/app_strings.dart';
import 'package:smart_expense/services/api.dart';
import 'package:smart_expense/services/api_routes.dart';

class ExchangeRateController {
  static Future<Result<ExchangeRateModel>> convert(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) async {
    try {
      final response = await ApiService.get(ApiRoutes.rate, {
        'amount': amount,
        'from_currency': fromCurrency,
        'to_currency': toCurrency,
      });
      final results = response.data['results'];
      final rate = results['exchange_rate'];
      // print('Exchange rate : $rate');
      final exchangeRateModel = ExchangeRateModel.fromMap(rate);

      return Result(
        isSuccess: true,
        message: response.data['message'],
        results: exchangeRateModel,
      );
    } on DioException catch (e) {
      final message = ApiService.errorMessage(e);
      final errors = e.response?.data['errors'];
      // print('Converting $e');
      return Result(isSuccess: false, message: message, errors: errors);
    } catch (e) {
      return Result(
        isSuccess: false,
        message: AppStrings.anErrorOccurredTryAgain,
      );
    }
  }
}
