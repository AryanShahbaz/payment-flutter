import 'package:flutter/cupertino.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../models/transaction.dart';
import '../data/transaction_db.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<TransactionModel>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    _transactionsFuture = TransactionDatabase.instance.getAllTransactions();
  }

  void _goToAddScreen() async {
    await Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => const AddTransactionScreen()),
    );
    setState(() {
      _loadTransactions(); // Refresh list
    });
  }

  String _formatJalali(DateTime dateTime) {
    final j = Jalali.fromDateTime(dateTime);
    return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
  }

  Widget _buildTransactionItem(TransactionModel tx) {
    final isTransport = tx.title == 'حمل و نقل';
    return CupertinoListTile(
      title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('مبلغ: ${tx.amount.toStringAsFixed(0)} تومان'),
          Text('تاریخ: ${_formatJalali(tx.date)}'),
          if (isTransport && tx.source != null && tx.destination != null)
            Text('از ${tx.source} به ${tx.destination}'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('مدیریت حساب شخصی'),
      ),
      child: Stack(
        children: [
          SafeArea(
            child: FutureBuilder<List<TransactionModel>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CupertinoActivityIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('خطا: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('هیچ تراکنشی ثبت نشده.'));
                }

                final txs = snapshot.data!;
                return ListView.builder(
                  itemCount: txs.length,
                  itemBuilder: (ctx, i) => _buildTransactionItem(txs[i]),
                );
              },
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: CupertinoButton.filled(
              child: const Icon(CupertinoIcons.add),
              onPressed: _goToAddScreen,
            ),
          ),
        ],
      ),
    );
  }
}
