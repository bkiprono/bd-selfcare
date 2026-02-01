import 'package:bdoneapp/models/common/statement_summary.dart';

class Statement {
  final String id;
  final String clientId;
  final String statementNumber;
  final DateTime startDate;
  final DateTime endDate;
  final String currencyId;
  final String status; // PENDING, GENERATED, FAILED
  final String? statementLink;
  final StatementSummary? summary;
  final DateTime createdAt;
  final DateTime updatedAt;

  Statement({
    required this.id,
    required this.clientId,
    required this.statementNumber,
    required this.startDate,
    required this.endDate,
    required this.currencyId,
    required this.status,
    this.statementLink,
    this.summary,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Statement.fromJson(Map<String, dynamic> json) {
    return Statement(
      id: json['_id'] ?? json['id'] ?? '',
      clientId: json['clientId'] ?? '',
      statementNumber: json['statementNumber'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      currencyId: json['currencyId'] ?? '',
      status: json['status'] ?? 'PENDING',
      statementLink: json['statementLink'],
      summary: json['summary'] != null
          ? StatementSummary.fromJson(json['summary'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'clientId': clientId,
      'statementNumber': statementNumber,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'currencyId': currencyId,
      'status': status,
      'statementLink': statementLink,
      'summary': summary?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Statement copyWith({
    String? id,
    String? clientId,
    String? statementNumber,
    DateTime? startDate,
    DateTime? endDate,
    String? currencyId,
    String? status,
    String? statementLink,
    StatementSummary? summary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Statement(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      statementNumber: statementNumber ?? this.statementNumber,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      currencyId: currencyId ?? this.currencyId,
      status: status ?? this.status,
      statementLink: statementLink ?? this.statementLink,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
