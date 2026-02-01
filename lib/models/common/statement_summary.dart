class StatementSummary {
  final double openingBalance;
  final double totalDebits;
  final double totalCredits;
  final double closingBalance;

  StatementSummary({
    required this.openingBalance,
    required this.totalDebits,
    required this.totalCredits,
    required this.closingBalance,
  });

  factory StatementSummary.fromJson(Map<String, dynamic> json) {
    return StatementSummary(
      openingBalance: (json['openingBalance'] ?? 0).toDouble(),
      totalDebits: (json['totalDebits'] ?? 0).toDouble(),
      totalCredits: (json['totalCredits'] ?? 0).toDouble(),
      closingBalance: (json['closingBalance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'openingBalance': openingBalance,
      'totalDebits': totalDebits,
      'totalCredits': totalCredits,
      'closingBalance': closingBalance,
    };
  }
}
