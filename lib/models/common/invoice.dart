import 'package:equatable/equatable.dart';
import 'package:bdoneapp/models/common/client.dart';

class Invoice extends Equatable {
  final String id;
  final String clientId;
  final String currencyId;
  final String orderId;
  final String serial;
  final double subTotal;
  final String status;
  final DateTime dueDate;
  final String paymentTerms;
  final String notes;
  final Client client;
  final double taxAmount;
  final double taxRate;
  final double totalAmount;
  final double amountPaid;
  final bool isDraft;
  final double amountDue;
  final String createdBy;
  final DateTime createdAt;
  final String invoiceLink;

  const Invoice({
    required this.id,
    required this.clientId,
    required this.currencyId,
    required this.orderId,
    required this.serial,
    required this.subTotal,
    required this.status,
    required this.dueDate,
    required this.paymentTerms,
    required this.notes,
    required this.taxAmount,
    required this.taxRate,
    required this.totalAmount,
    required this.amountPaid,
    required this.isDraft,
    required this.amountDue,
    required this.createdBy,
    required this.createdAt,
    required this.invoiceLink, 
    required this.client,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['_id'] ?? '',
      clientId: json['clientId'] ?? '',
      currencyId: json['currencyId'] ?? '',
      orderId: json['orderId'] ?? '',
      serial: json['serial'] ?? '',
      subTotal: (json['subTotal'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : DateTime.now(),
      paymentTerms: json['paymentTerms'] ?? '',
      notes: json['notes'] ?? '',
      client: Client.fromJson(json['client'] ?? {}),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      taxRate: (json['taxRate'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      isDraft: json['isDraft'] ?? false,
      amountDue: (json['amountDue'] ?? 0).toDouble(),
      createdBy: json['createdBy'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      invoiceLink: json['invoiceLink'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'clientId': clientId,
      'currencyId': currencyId,
      'orderId': orderId,
      'serial': serial,
      'subTotal': subTotal,
      'status': status,
      'dueDate': dueDate.toIso8601String(),
      'paymentTerms': paymentTerms,
      'notes': notes,
      'client': client.toJson(),
      'taxAmount': taxAmount,
      'taxRate': taxRate,
      'totalAmount': totalAmount,
      'amountPaid': amountPaid,
      'isDraft': isDraft,
      'amountDue': amountDue,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'invoiceLink': invoiceLink,
    };
  }

  Invoice copyWith({
    String? id,
    String? clientId,
    String? currencyId,
    String? orderId,
    String? serial,
    double? subTotal,
    String? status,
    DateTime? dueDate,
    String? paymentTerms,
    String? notes,
    Client? client,
    double? taxAmount,
    double? taxRate,
    double? totalAmount,
    double? amountPaid,
    bool? isDraft,
    double? amountDue,
    String? createdBy,
    DateTime? createdAt,
    int? v,
    String? invoiceLink,
  }) {
    return Invoice(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      currencyId: currencyId ?? this.currencyId,
      orderId: orderId ?? this.orderId,
      serial: serial ?? this.serial,
      subTotal: subTotal ?? this.subTotal,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      notes: notes ?? this.notes,
      client: client ?? this.client,
      taxAmount: taxAmount ?? this.taxAmount,
      taxRate: taxRate ?? this.taxRate,
      totalAmount: totalAmount ?? this.totalAmount,
      amountPaid: amountPaid ?? this.amountPaid,
      isDraft: isDraft ?? this.isDraft,
      amountDue: amountDue ?? this.amountDue,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      invoiceLink: invoiceLink ?? this.invoiceLink,
    );
  }

  @override
  List<Object?> get props => [
        id,
        clientId,
        currencyId,
        orderId,
        serial,
        subTotal,
        status,
        dueDate,
        paymentTerms,
        notes,
        client,
        taxAmount,
        taxRate,
        totalAmount,
        amountPaid,
        isDraft,
        amountDue,
        createdBy,
        createdAt,
        invoiceLink,
      ];
}

