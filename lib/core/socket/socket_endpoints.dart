import 'package:bdoneapp/core/endpoints.dart';
import 'package:bdoneapp/components/logger_config.dart';

String socketUrl() {
  // Convert HTTPS URL to WSS URL for WebSocket connection
  const serverUrl = ApiEndpoints.serverUrl;
  if (serverUrl.startsWith('https://')) {
    return serverUrl.replaceFirst('https://', 'wss://');
  } else if (serverUrl.startsWith('http://')) {
    return serverUrl.replaceFirst('http://', 'ws://');
  }
  logger.d('Server URL: $serverUrl');
  return serverUrl; // Fallback to original URL
}
