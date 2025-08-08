import 'package:flutter/material.dart';
import 'package:smart_expense/resources/app_colours.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartComponent extends StatefulWidget {
  const ChartComponent({super.key});

  @override
  State<ChartComponent> createState() => _ChartComponentState();
}

class _ChartComponentState extends State<ChartComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      child: SfCartesianChart(
        palette: [Colors.red, Colors.green, Colors.blue],
        primaryXAxis: CategoryAxis(),
        series: <SplineSeries<SaleData, String>>[
          SplineSeries<SaleData, String>(
            color: AppColours.primaryColour,
            dataSource: <SaleData>[
              SaleData(100, 'Mon'),
              SaleData(20, 'Tue'),
              SaleData(400, 'Wed'),
              SaleData(150, 'Thu'),
              SaleData(10, 'Fri'),
              SaleData(500, 'Sate'),
              SaleData(100, 'Sun'),
            ],
            xValueMapper: (SaleData sales, _) => sales.year,
            yValueMapper: (SaleData sales, _) => sales.sales,
          ),
        ],
      ),
    );
  }
}

class SaleData {
  SaleData(this.sales, this.year);
  final String year;
  final int sales;
}
