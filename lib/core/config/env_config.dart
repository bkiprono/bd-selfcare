class EnvConfig {
  // static const String domainUrl = 'https://shop.bdcomputing.co.ke';
  static const String domainUrl = 'https://wadable-sidesplittingly-lashawn.ngrok-free.dev';
  static const String devBaseUrl = '$domainUrl/api';
  static const String prodBaseUrl = '$domainUrl/api';

  // For now, defaulting to prod. In a real world scenario, use --dart-define or similar
  static const String baseUrl = prodBaseUrl;

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
