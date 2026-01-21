class PesapalError {
  final String errorType;
  final String code;
  final String message;

  PesapalError({
    required this.errorType,
    required this.code,
    required this.message,
  });

  factory PesapalError.fromJson(Map<String, dynamic> json) {
    return PesapalError(
      errorType: json['error_type'] as String,
      code: json['code'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error_type': errorType,
      'code': code,
      'message': message,
    };
  }
}
