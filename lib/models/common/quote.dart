import 'package:equatable/equatable.dart';
import 'package:bdoneapp/models/common/client.dart';
import 'package:bdoneapp/models/common/quote_item.dart';
import 'package:bdoneapp/models/enums/quote_status.dart';

class Quote extends Equatable {
  final String id;
  final String serial;
  final String status;
  final String? leadId;
  final String? clientId;
  final String leadProjectId;
  final String currencyId;
  final DateTime dateIssued;
  final DateTime validUntil;
  final double subTotal;
  final double taxAmount;
  final double taxRate;
  final bool taxInclusive;
  final double discount;
  final bool discountPercentage;
  final double discountAmount;
  final double totalAmount;
  final String? paymentTerms;
  final String? notes;
  final String? quoteLink;
  final bool isDraft;
  final bool approved;
  final String? invoiceId;
  final Client? client;
  final List<QuoteItem> items;
  final DateTime createdAt;
  final String createdBy;

  const Quote({
    required this.id,
    required this.serial,
    required this.status,
    this.leadId,
    this.clientId,
    required this.leadProjectId,
    required this.currencyId,
    required this.dateIssued,
    required this.validUntil,
    required this.subTotal,
    required this.taxAmount,
    required this.taxRate,
    required this.taxInclusive,
    required this.discount,
    required this.discountPercentage,
    required this.discountAmount,
    required this.totalAmount,
    this.paymentTerms,
    this.notes,
    this.quoteLink,
    required this.isDraft,
    required this.approved,
    this.invoiceId,
    this.client,
    required this.items,
    required this.createdAt,
    required this.createdBy,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['_id'] ?? '',
      serial: json['serial'] ?? '',
      status: json['status'] ?? 'DRAFT',
      leadId: json['leadId'],
      clientId: json['clientId'],
      leadProjectId: json['leadProjectId'] ?? '',
      currencyId: json['currencyId'] ?? '',
      dateIssued: json['dateIssued'] != null
          ? DateTime.parse(json['dateIssued'])
          : DateTime.now(),
      validUntil: json['validUntil'] != null
          ? DateTime.parse(json['validUntil'])
          : DateTime.now(),
      subTotal: (json['subTotal'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? 0).toDouble(),
      taxRate: (json['taxRate'] ?? 0).toDouble(),
      taxInclusive: json['taxInclusive'] ?? false,
      discount: (json['discount'] ?? 0).toDouble(),
      discountPercentage: json['discountPercentage'] ?? false,
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentTerms: json['paymentTerms'],
      notes: json['notes'],
      quoteLink: json['quoteLink'],
      isDraft: json['isDraft'] ?? false,
      approved: json['approved'] ?? false,
      invoiceId: json['invoiceId'],
      client: json['client'] != null ? Client.fromJson(json['client']) : null,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => QuoteItem.fromJson(item))
              .toList()
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      createdBy: json['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'serial': serial,
      'status': status,
      'leadId': leadId,
      'clientId': clientId,
      'leadProjectId': leadProjectId,
      'currencyId': currencyId,
      'dateIssued': dateIssued.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'subTotal': subTotal,
      'taxAmount': taxAmount,
      'taxRate': taxRate,
      'taxInclusive': taxInclusive,
      'discount': discount,
      'discountPercentage': discountPercentage,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'paymentTerms': paymentTerms,
      'notes': notes,
      'quoteLink': quoteLink,
      'isDraft': isDraft,
      'approved': approved,
      'invoiceId': invoiceId,
      'client': client?.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  QuoteStatus get quoteStatus => QuoteStatus.fromString(status);

  @override
  List<Object?> get props => [
        id,
        serial,
        status,
        leadId,
        clientId,
        leadProjectId,
        currencyId,
        dateIssued,
        validUntil,
        subTotal,
        taxAmount,
        taxRate,
        taxInclusive,
        discount,
        discountPercentage,
        discountAmount,
        totalAmount,
        paymentTerms,
        notes,
        quoteLink,
        isDraft,
        approved,
        invoiceId,
        client,
        items,
        createdAt,
        createdBy,
      ];
}
