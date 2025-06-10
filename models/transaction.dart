class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;
  final String? source;
  final String? destination;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.source,
    this.destination,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'source': source,
      'destination': destination,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      source: map['source'],
      destination: map['destination'],
    );
  }
}
