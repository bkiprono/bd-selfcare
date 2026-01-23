class CashPayment {
  final String clientId;
  final String? invoiceId;
  final double amountPaid;
  final DateTime paymentDate;
  final String currencyId;
  final String? reference;
  final String? description;

  CashPayment({
    required this.clientId,
    this.invoiceId,
    required this.amountPaid,
    required this.paymentDate,
    required this.currencyId,
    this.reference,
    this.description,
  });

  factory CashPayment.fromJson(Map<String, dynamic> json) {
    return CashPayment(
      clientId: (json['clientId'] ?? '').toString(),
      invoiceId: json['invoiceId']?.toString(),
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : DateTime.now(),
      currencyId: (json['currencyId'] ?? '').toString(),
      reference: json['reference']?.toString(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'invoiceId': invoiceId,
      'amountPaid': amountPaid,
      'paymentDate': paymentDate.toIso8601String(),
      'currencyId': currencyId,
      'reference': reference,
      'description': description,
    };
  }
}

class ChequePayment {
  final String clientId;
  final String? invoiceId;
  final String chequeNumber;
  final String bankName;
  final String drawerName;
  final double amountPaid;
  final DateTime paymentDate;
  final String currencyId;
  final String? description;

  ChequePayment({
    required this.clientId,
    this.invoiceId,
    required this.chequeNumber,
    required this.bankName,
    required this.drawerName,
    required this.amountPaid,
    required this.paymentDate,
    required this.currencyId,
    this.description,
  });

  factory ChequePayment.fromJson(Map<String, dynamic> json) {
    return ChequePayment(
      clientId: (json['clientId'] ?? '').toString(),
      invoiceId: json['invoiceId']?.toString(),
      chequeNumber: (json['chequeNumber'] ?? '').toString(),
      bankName: (json['bankName'] ?? '').toString(),
      drawerName: (json['drawerName'] ?? '').toString(),
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : DateTime.now(),
      currencyId: (json['currencyId'] ?? '').toString(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'invoiceId': invoiceId,
      'chequeNumber': chequeNumber,
      'bankName': bankName,
      'drawerName': drawerName,
      'amountPaid': amountPaid,
      'paymentDate': paymentDate.toIso8601String(),
      'currencyId': currencyId,
      'description': description,
    };
  }
}

class BankTransferPayment {
  final String clientId;
  final String? invoiceId;
  final String accountNumber;
  final String accountName;
  final String bankName;
  final String drawerName;
  final double amountPaid;
  final String transferReference;
  final DateTime paymentDate;
  final String currencyId;
  final String? description;

  BankTransferPayment({
    required this.clientId,
    this.invoiceId,
    required this.accountNumber,
    required this.accountName,
    required this.bankName,
    required this.drawerName,
    required this.amountPaid,
    required this.transferReference,
    required this.paymentDate,
    required this.currencyId,
    this.description,
  });

  factory BankTransferPayment.fromJson(Map<String, dynamic> json) {
    return BankTransferPayment(
      clientId: (json['clientId'] ?? '').toString(),
      invoiceId: json['invoiceId']?.toString(),
      accountNumber: (json['accountNumber'] ?? '').toString(),
      accountName: (json['accountName'] ?? '').toString(),
      bankName: (json['bankName'] ?? '').toString(),
      drawerName: (json['drawerName'] ?? '').toString(),
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      transferReference: (json['transferReference'] ?? '').toString(),
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : DateTime.now(),
      currencyId: (json['currencyId'] ?? '').toString(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'invoiceId': invoiceId,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'bankName': bankName,
      'drawerName': drawerName,
      'amountPaid': amountPaid,
      'transferReference': transferReference,
      'paymentDate': paymentDate.toIso8601String(),
      'currencyId': currencyId,
      'description': description,
    };
  }
}

class BankDepositPayment {
  final String clientId;
  final String? invoiceId;
  final String accountNumber;
  final String accountName;
  final String bankName;
  final String drawerName;
  final double amountPaid;
  final DateTime paymentDate;
  final String depositReference;
  final String currencyId;
  final String? description;

  BankDepositPayment({
    required this.clientId,
    this.invoiceId,
    required this.accountNumber,
    required this.accountName,
    required this.bankName,
    required this.drawerName,
    required this.amountPaid,
    required this.paymentDate,
    required this.depositReference,
    required this.currencyId,
    this.description,
  });

  factory BankDepositPayment.fromJson(Map<String, dynamic> json) {
    return BankDepositPayment(
      clientId: (json['clientId'] ?? '').toString(),
      invoiceId: json['invoiceId']?.toString(),
      accountNumber: (json['accountNumber'] ?? '').toString(),
      accountName: (json['accountName'] ?? '').toString(),
      bankName: (json['bankName'] ?? '').toString(),
      drawerName: (json['drawerName'] ?? '').toString(),
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : DateTime.now(),
      depositReference: (json['depositReference'] ?? '').toString(),
      currencyId: (json['currencyId'] ?? '').toString(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'invoiceId': invoiceId,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'bankName': bankName,
      'drawerName': drawerName,
      'amountPaid': amountPaid,
      'paymentDate': paymentDate.toIso8601String(),
      'depositReference': depositReference,
      'currencyId': currencyId,
      'description': description,
    };
  }
}

class ManualMpesaPayment {
  final String clientId;
  final double amountPaid;
  final DateTime paymentDate;
  final String mpesaReference;
  final String? invoiceId;
  final String currencyId;
  final String? description;

  ManualMpesaPayment({
    required this.clientId,
    required this.amountPaid,
    required this.paymentDate,
    required this.mpesaReference,
    this.invoiceId,
    required this.currencyId,
    this.description,
  });

  factory ManualMpesaPayment.fromJson(Map<String, dynamic> json) {
    return ManualMpesaPayment(
      clientId: (json['clientId'] ?? '').toString(),
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : DateTime.now(),
      mpesaReference: (json['mpesaReference'] ?? '').toString(),
      invoiceId: json['invoiceId']?.toString(),
      currencyId: (json['currencyId'] ?? '').toString(),
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'amountPaid': amountPaid,
      'paymentDate': paymentDate.toIso8601String(),
      'mpesaReference': mpesaReference,
      'invoiceId': invoiceId,
      'currencyId': currencyId,
      'description': description,
    };
  }
}

class MpesaTransaction {
  final String? id;
  final String? merchantRequestID;
  final String? checkoutRequestID;
  final int? resultCode;
  final String? resultDesc;
  final double? amount;
  final String? mpesaReceiptNumber;
  final DateTime? transactionDate;
  final String? phoneNumber;
  final String? accountNumber;
  final String? clientId;
  final String? invoiceId;
  final bool isUsed;
  final String? name;
  final bool? isDirectPayment;
  final String createdBy;

  MpesaTransaction({
    this.id,
    this.merchantRequestID,
    this.checkoutRequestID,
    this.resultCode,
    this.resultDesc,
    this.amount,
    this.mpesaReceiptNumber,
    this.transactionDate,
    this.phoneNumber,
    this.accountNumber,
    this.clientId,
    this.invoiceId,
    this.isUsed = false,
    this.name,
    this.isDirectPayment,
    required this.createdBy,
  });

  factory MpesaTransaction.fromJson(Map<String, dynamic> json) {
    return MpesaTransaction(
      id: (json['_id'] ?? json['id'])?.toString(),
      merchantRequestID: json['merchantRequestID']?.toString(),
      checkoutRequestID: json['checkoutRequestID']?.toString(),
      resultCode: json['resultCode'] as int?,
      resultDesc: json['resultDesc']?.toString(),
      amount: (json['amount'] ?? 0).toDouble(),
      mpesaReceiptNumber: json['mpesaReceiptNumber']?.toString(),
      transactionDate: json['transactionDate'] != null
          ? DateTime.parse(json['transactionDate'])
          : null,
      phoneNumber: json['phoneNumber']?.toString(),
      accountNumber: json['accountNumber']?.toString(),
      clientId: json['clientId']?.toString(),
      invoiceId: json['invoiceId']?.toString(),
      isUsed: json['isUsed'] ?? false,
      name: json['name']?.toString(),
      isDirectPayment: json['isDirectPayment'],
      createdBy: (json['createdBy'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchantRequestID': merchantRequestID,
      'checkoutRequestID': checkoutRequestID,
      'resultCode': resultCode,
      'resultDesc': resultDesc,
      'amount': amount,
      'mpesaReceiptNumber': mpesaReceiptNumber,
      'transactionDate': transactionDate?.toIso8601String(),
      'phoneNumber': phoneNumber,
      'accountNumber': accountNumber,
      'clientId': clientId,
      'invoiceId': invoiceId,
      'isUsed': isUsed,
      'name': name,
      'isDirectPayment': isDirectPayment,
      'createdBy': createdBy,
    };
  }
}

class PesapalDetailedResponse {
  final String paymentRequestId;
  final String paymentMethod;
  final double amount;
  final DateTime createdDate;
  final String confirmationCode;
  final String orderTrackingId;
  final String paymentStatusDescription;
  final String? description;
  final String message;
  final String paymentAccount;
  final String callBackUrl;
  final int statusCode;
  final String merchantReference;
  final String? account_number;
  final String paymentStatusCode;
  final String currency;
  final String status;
  final String currencyId;

  PesapalDetailedResponse({
    required this.paymentRequestId,
    required this.paymentMethod,
    required this.amount,
    required this.createdDate,
    required this.confirmationCode,
    required this.orderTrackingId,
    required this.paymentStatusDescription,
    this.description,
    required this.message,
    required this.paymentAccount,
    required this.callBackUrl,
    required this.statusCode,
    required this.merchantReference,
    this.account_number,
    required this.paymentStatusCode,
    required this.currency,
    required this.status,
    required this.currencyId,
  });

  factory PesapalDetailedResponse.fromJson(Map<String, dynamic> json) {
    return PesapalDetailedResponse(
      paymentRequestId: (json['paymentRequestId'] ?? '').toString(),
      paymentMethod: (json['payment_method'] ?? '').toString(),
      amount: (json['amount'] ?? 0).toDouble(),
      createdDate: json['created_date'] != null
          ? DateTime.parse(json['created_date'])
          : DateTime.now(),
      confirmationCode: (json['confirmation_code'] ?? '').toString(),
      orderTrackingId: (json['order_tracking_id'] ?? '').toString(),
      paymentStatusDescription: (json['payment_status_description'] ?? '').toString(),
      description: json['description']?.toString(),
      message: (json['message'] ?? '').toString(),
      paymentAccount: (json['payment_account'] ?? '').toString(),
      callBackUrl: (json['call_back_url'] ?? '').toString(),
      statusCode: json['status_code'] as int? ?? 0,
      merchantReference: (json['merchant_reference'] ?? '').toString(),
      account_number: json['account_number']?.toString(),
      paymentStatusCode: (json['payment_status_code'] ?? '').toString(),
      currency: (json['currency'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      currencyId: (json['currencyId'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentRequestId': paymentRequestId,
      'payment_method': paymentMethod,
      'amount': amount,
      'created_date': createdDate.toIso8601String(),
      'confirmation_code': confirmationCode,
      'order_tracking_id': orderTrackingId,
      'payment_status_description': paymentStatusDescription,
      'description': description,
      'message': message,
      'payment_account': paymentAccount,
      'call_back_url': callBackUrl,
      'status_code': statusCode,
      'merchant_reference': merchantReference,
      'account_number': account_number,
      'payment_status_code': paymentStatusCode,
      'currency': currency,
      'status': status,
      'currencyId': currencyId,
    };
  }
}
