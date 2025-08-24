class ExchangeRateModel {
  late String amount;
  late String fromCurrency;
  late String toCurrency;
  late double rate;

  static ExchangeRateModel fromMap(Map<String, dynamic> exchangeRate) {
    var exchangeRateModel = ExchangeRateModel();

    exchangeRateModel.amount = exchangeRate['amount'];
    exchangeRateModel.fromCurrency = exchangeRate['from'];
    exchangeRateModel.toCurrency = exchangeRate['to'];
    exchangeRateModel.rate = exchangeRate['rate'];

    return exchangeRateModel;
  }
}
