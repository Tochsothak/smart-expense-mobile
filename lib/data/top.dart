import 'package:smart_expense/data/money.dart';

List<Money> getterTop() {
  List<Money> moneys = [
    Money(
      name: 'Snap food',
      image: 'snap_food.jpg',
      time: 'jan 30, 2022',
      fee: '\$ 100',
      buy: true,
    ),
    Money(
      name: 'Transfer',
      image: 'aba.png',
      time: 'Today',
      fee: '\$ 60',
      buy: true,
    ),
  ];
  return moneys;
}
