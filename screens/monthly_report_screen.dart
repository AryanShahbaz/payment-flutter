import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../data/transaction_db.dart';
import '../models/transaction.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  int selectedYear = Jalali.now().year;
  int selectedMonth = Jalali.now().month;

  List<TransactionModel> monthlyTransactions = [];
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    final allTx = await TransactionDatabase.instance.getAllTransactions();
    final filtered = allTx.where((tx) {
      final j = Jalali.fromDateTime(tx.date);
      return j.year == selectedYear && j.month == selectedMonth;
    }).toList();

    setState(() {
      monthlyTransactions = filtered;
      totalAmount = filtered.fold(0, (sum, tx) => sum + tx.amount);
    });
  }

  Widget _buildPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CupertinoButton(
          child: Text('سال: $selectedYear'),
          onPressed: () => _selectYear(),
        ),
        CupertinoButton(
          child: Text('ماه: $selectedMonth'),
          onPressed: () => _selectMonth(),
        ),
      ],
    );
  }

  void _selectYear() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => SizedBox(
        height: 250,
        child: CupertinoPicker(
          itemExtent: 32,
          scrollController: FixedExtentScrollController(initialItem: 10),
          onSelectedItemChanged: (index) {
            setState(() {
              selectedYear = 1395 + index;
              _loadReport();
            });
          },
          children: List.generate(30, (i) => Text('${1395 + i}')),
        ),
      ),
    );
  }

  void _selectMonth() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => SizedBox(
        height: 250,
        child: CupertinoPicker(
          itemExtent: 32,
          scrollController: FixedExtentScrollController(initialItem: selectedMonth - 1),
          onSelectedItemChanged: (index) {
            setState(() {
              selectedMonth = index + 1;
              _loadReport();
            });
          },
          children: List.generate(12, (i) => Text('${i + 1}')),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('گزارش ماهانه'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildPicker(),
            const SizedBox(height: 16),
            Text(
              'مجموع هزینه‌ها: ${totalAmount.toStringAsFixed(0)} تومان',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: monthlyTransactions.length,
                itemBuilder: (context, index) {
                  final tx = monthlyTransactions[index];
                  return CupertinoListTile(
                    title: Text(tx.title),
                    subtitle: Text('مبلغ: ${tx.amount.toInt()} - ${Jalali.fromDateTime(tx.date).formatCompactDate()}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
