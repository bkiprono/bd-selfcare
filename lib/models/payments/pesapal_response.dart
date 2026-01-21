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
      orderTrackingId: json['order_tracking_id'] as String,
      merchantReference: json['merchant_reference'] as String,
      redirectUrl: json['redirect_url'] as String,
      error: json['error'] as String?,
      status: json['status'] as String,
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
