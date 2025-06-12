// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:shamsi_date/shamsi_date.dart';
// import '../models/transaction.dart';

// class AddTransactionScreen extends StatefulWidget {
//   const AddTransactionScreen({super.key});

//   @override
//   State<AddTransactionScreen> createState() => _AddTransactionScreenState();
// }

// class _AddTransactionScreenState extends State<AddTransactionScreen> {
//   final _titleController = TextEditingController();
//   final _amountController = TextEditingController();
//   final _sourceController = TextEditingController();
//   final _destinationController = TextEditingController();

//   DateTime _selectedDate = DateTime.now();

//   void _submitData() {
//     final enteredTitle = _titleController.text;
//     final enteredAmount = double.tryParse(_amountController.text) ?? 0;

//     if (enteredTitle.isEmpty || enteredAmount <= 0) {
//       return;
//     }

//     final newTx = TransactionModel(
//       title: enteredTitle,
//       amount: enteredAmount,
//       date: _selectedDate,
//       source: enteredTitle == 'حمل و نقل' ? _sourceController.text : null,
//       destination: enteredTitle == 'حمل و نقل' ? _destinationController.text : null,
//     );

//     Navigator.of(context).pop(newTx);
//   }

//   void _presentDatePicker() {
//     showCupertinoModalPopup(
//       context: context,
//       builder: (_) => SizedBox(
//         height: 250,
//         child: CupertinoDatePicker(
//           mode: CupertinoDatePickerMode.date,
//           initialDateTime: _selectedDate,
//           maximumDate: DateTime.now(),
//           onDateTimeChanged: (pickedDate) {
//             setState(() {
//               _selectedDate = pickedDate;
//             });
//           },
//         ),
//       ),
//     );
//   }

//   String _formatJalali(DateTime date) {
//     final j = Jalali.fromDateTime(date);
//     return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isTransport = _titleController.text.trim() == 'حمل و نقل';

//     return CupertinoPageScaffold(
//       navigationBar: const CupertinoNavigationBar(
//         middle: Text('افزودن تراکنش'),
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: ListView(
//             children: [
//               CupertinoTextField(
//                 controller: _titleController,
//                 placeholder: 'عنوان',
//                 onChanged: (_) => setState(() {}),
//               ),
//               const SizedBox(height: 12),
//               CupertinoTextField(
//                 controller: _amountController,
//                 placeholder: 'مبلغ (تومان)',
//                 keyboardType: TextInputType.number,
//               ),
//               const SizedBox(height: 12),
//               CupertinoButton(
//                 child: Text('انتخاب تاریخ: ${_formatJalali(_selectedDate)}'),
//                 onPressed: _presentDatePicker,
//               ),
//               const SizedBox(height: 12),
//               if (isTransport) ...[
//                 CupertinoTextField(
//                   controller: _sourceController,
//                   placeholder: 'مبدا',
//                 ),
//                 const SizedBox(height: 12),
//                 CupertinoTextField(
//                   controller: _destinationController,
//                   placeholder: 'مقصد',
//                 ),
//               ],
//               const SizedBox(height: 20),
//               CupertinoButton.filled(
//                 child: const Text('ثبت تراکنش'),
//                 onPressed: _submitData,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import '../models/transaction.dart';
import '../data/transaction_db.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController();
  final _destinationController = TextEditingController();

  Jalali _selectedJalaliDate = Jalali.now();

  Future<void> _submitData() async {
    final enteredTitle = _titleController.text.trim();
    final enteredAmount = double.tryParse(_amountController.text) ?? 0;

    if (enteredTitle.isEmpty || enteredAmount <= 0) return;

    final newTx = TransactionModel(
      title: enteredTitle,
      amount: enteredAmount,
      date: _selectedJalaliDate.toDateTime(),
      source: enteredTitle == 'حمل و نقل' ? _sourceController.text.trim() : null,
      destination: enteredTitle == 'حمل و نقل' ? _destinationController.text.trim() : null,
    );

    await TransactionDatabase.instance.insertTransaction(newTx);

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _presentDatePicker() async {
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: _selectedJalaliDate,
      firstDate: Jalali(1390, 1),
      lastDate: Jalali(1450, 12),
    );
    if (picked != null) {
      setState(() {
        _selectedJalaliDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTransport = _titleController.text.trim() == 'حمل و نقل';

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('افزودن تراکنش'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              CupertinoTextField(
                controller: _titleController,
                placeholder: 'عنوان',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _amountController,
                placeholder: 'مبلغ (تومان)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CupertinoButton(
                child: Text('انتخاب تاریخ: ${_selectedJalaliDate.formatCompactDate()}'),
                onPressed: _presentDatePicker,
              ),
              const SizedBox(height: 12),
              if (isTransport) ...[
                CupertinoTextField(
                  controller: _sourceController,
                  placeholder: 'مبدا',
                ),
                const SizedBox(height: 12),
                CupertinoTextField(
                  controller: _destinationController,
                  placeholder: 'مقصد',
                ),
              ],
              const SizedBox(height: 20),
              CupertinoButton.filled(
                child: const Text('ثبت تراکنش'),
                onPressed: _submitData,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

