class CurrencyBreakdown {
  final String currency;
  final double originalAmount;
  final double convertedAmount;
  final int transactionCount;
  final double exchangeRate;

  CurrencyBreakdown({
    required this.currency,
    required this.originalAmount,
    required this.convertedAmount,
    required this.transactionCount,
    required this.exchangeRate,
  });
}
