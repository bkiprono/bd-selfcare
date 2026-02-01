class StatementTransaction {
  final DateTime date;
  final String reference;
  final String description;
  final double debit;
  final double credit;
  final double balance;

  StatementTransaction({
    required this.date,
    required this.reference,
    required this.description,
    required this.debit,
    required this.credit,
    required this.balance,
  });

  factory StatementTransaction.fromJson(Map<String, dynamic> json) {
    return StatementTransaction(
      date: DateTime.parse(json['date']),
      reference: json['reference'] ?? '',
      description: json['description'] ?? '',
      debit: (json['debit'] ?? 0).toDouble(),
      credit: (json['credit'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'reference': reference,
      'description': description,
      'debit': debit,
      'credit': credit,
      'balance': balance,
    };
  }
}
