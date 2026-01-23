class MpesaStkResponse {
  final String merchantRequestID;
  final String checkoutRequestID;
  final String responseCode;
  final String responseDescription;
  final String customerMessage;

  MpesaStkResponse({
    required this.merchantRequestID,
    required this.checkoutRequestID,
    required this.responseCode,
    required this.responseDescription,
    required this.customerMessage,
  });

  factory MpesaStkResponse.fromJson(Map<String, dynamic> json) {
    return MpesaStkResponse(
      merchantRequestID: (json['MerchantRequestID'] ?? '').toString(),
      checkoutRequestID: (json['CheckoutRequestID'] ?? '').toString(),
      responseCode: (json['ResponseCode'] ?? '').toString(),
      responseDescription: (json['ResponseDescription'] ?? '').toString(),
      customerMessage: (json['CustomerMessage'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MerchantRequestID': merchantRequestID,
      'CheckoutRequestID': checkoutRequestID,
      'ResponseCode': responseCode,
      'ResponseDescription': responseDescription,
      'CustomerMessage': customerMessage,
    };
  }
}
