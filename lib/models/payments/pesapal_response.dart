class PesapalResponse {
  final String orderTrackingId;
  final String merchantReference;
  final String redirectUrl;
  final String? error;
  final String status;

  PesapalResponse({
    required this.orderTrackingId,
    required this.merchantReference,
    required this.redirectUrl,
    required this.error,
    required this.status,
  });

  factory PesapalResponse.fromJson(Map<String, dynamic> json) {
    return PesapalResponse(
      orderTrackingId: (json['order_tracking_id'] ?? '').toString(),
      merchantReference: (json['merchant_reference'] ?? '').toString(),
      redirectUrl: (json['redirect_url'] ?? '').toString(),
      error: json['error']?.toString(),
      status: (json['status'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_tracking_id': orderTrackingId,
      'merchant_reference': merchantReference,
      'redirect_url': redirectUrl,
      'error': error,
      'status': status,
    };
  }
}
