import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import '../data/transaction_db.dart';
import '../models/transaction.dart';

class ExcelExportScreen extends StatefulWidget {
  const ExcelExportScreen({super.key});

  @override
  State<ExcelExportScreen> createState() => _ExcelExportScreenState();
}

class _ExcelExportScreenState extends State<ExcelExportScreen> {
  bool _isExporting = false;
  String _message = '';

  Future<void> _exportToExcel() async {
    setState(() {
      _isExporting = true;
      _message = '';
    });

    // درخواست دسترسی ذخیره‌سازی (برای اندروید)
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        setState(() {
          _isExporting = false;
          _message = 'دسترسی ذخیره‌سازی رد شد.';
        });
        return;
      }
    }

    try {
      final transactions = await TransactionDatabase.instance.getAllTransactions();

      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Transactions'];

      // هدر ستون‌ها
      sheetObject.appendRow([
        TextCellValue('عنوان'),
        TextCellValue('مبلغ'),
        TextCellValue('تاریخ (شمسی)'),
        TextCellValue('مبدا'),
        TextCellValue('مقصد'),
      ]);


      for (var tx in transactions) {
        final jDate = Jalali.fromDateTime(tx.date);
        String formattedDate = '${jDate.year}/${jDate.month.toString().padLeft(2, '0')}/${jDate.day.toString().padLeft(2, '0')}';

        sheetObject.appendRow([
          TextCellValue(tx.title),
          TextCellValue(tx.amount.toString()),
          TextCellValue(formattedDate),
          TextCellValue(tx.source ?? ''),
          TextCellValue(tx.destination ?? ''),
        ]);

      }

      final bytes = excel.encode();

      if (bytes == null) {
        setState(() {
          _isExporting = false;
          _message = 'خطا در تولید فایل اکسل.';
        });
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      final file = File(path);
      await file.writeAsBytes(bytes);

      setState(() {
        _isExporting = false;
        _message = 'فایل اکسل با موفقیت ذخیره شد:\n$path';
      });
    } catch (e) {
      setState(() {
        _isExporting = false;
        _message = 'خطا: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('خروجی اکسل'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CupertinoButton.filled(
                onPressed: _isExporting ? null : _exportToExcel,
                child: Text(_isExporting ? 'در حال ذخیره...' : 'خروجی گرفتن به اکسل'),
              ),
              const SizedBox(height: 20),
              if (_message.isNotEmpty)
                SelectableText(
                  _message,
                  style: const TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
