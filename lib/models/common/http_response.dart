/// A generic HTTP response model that supports any data type.
///
/// Example usage:
/// ```dart
/// final response = CustomHttpResponse<User>.fromJson(
///   json,
///   (data) => User.fromJson(data),
/// );
/// ```
class CustomHttpResponse<T> {
  final int statusCode;
  final String message;
  final T data;

  const CustomHttpResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  /// Creates a [CustomHttpResponse] instance from JSON.
  ///
  /// The [fromDataJson] function is used to deserialize the generic [data].
  factory CustomHttpResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromDataJson,
  ) {
    return CustomHttpResponse<T>(
      statusCode: json['statusCode'] is int
          ? json['statusCode'] as int
          : int.tryParse(json['statusCode'].toString()) ?? 0,
      message: json['message']?.toString() ?? '',
      data: fromDataJson(json['data']),
    );
  }

  /// Converts this object to a JSON-serializable map.
  Map<String, dynamic> toJson(Object Function(T value) toDataJson) {
    return {
      'statusCode': statusCode,
      'message': message,
      'data': toDataJson(data),
    };
  }

  /// Returns `true` if [statusCode] indicates success (200–299).
  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  @override
  String toString() =>
      'CustomHttpResponse(statusCode: $statusCode, message: $message, data: $data)';
}
