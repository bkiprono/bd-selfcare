import 'dart:async';
import 'package:bdcomputing/components/logger_config.dart';
import 'package:bdcomputing/core/socket/socket_endpoints.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  final String _token;
  final Map<String, IO.Socket> _sockets = {};
  
  SocketService({required String token}) : _token = token;

  /// Connects to a specific namespace and returns the socket instance.
  /// If a connection already exists for this namespace, it returns the existing one.
  IO.Socket connect(String namespace) {
    if (_sockets.containsKey(namespace)) {
      final socket = _sockets[namespace]!;
      if (socket.connected) return socket;
      socket.connect();
      return socket;
    }

    final url = socketUrl();
    logger.i('Connecting to socket: $url$namespace');

    final IO.Socket socket = IO.io(
      '$url$namespace',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'Authorization': 'Bearer $_token'})
          .enableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      logger.i('Socket connected to $namespace');
    });

    socket.onDisconnect((_) {
      logger.i('Socket disconnected from $namespace');
    });

    socket.onConnectError((err) {
      logger.e('Socket connect error in $namespace: $err');
    });

    socket.onError((err) {
      logger.e('Socket error in $namespace: $err');
    });

    _sockets[namespace] = socket;
    return socket;
  }

  /// Listens for a specific event on a namespace and returns a Stream.
  Stream<T> onEvent<T>(String namespace, String event) {
    final socket = connect(namespace);
    final controller = StreamController<T>();

    socket.on(event, (data) {
      logger.d('Socket event received: $event on $namespace');
      if (!controller.isClosed) {
        controller.add(data as T);
      }
    });

    // Clean up listener when stream is cancelled
    controller.onCancel = () {
      socket.off(event);
      controller.close();
    };

    return controller.stream;
  }

  /// Disconnects a specific namespace.
  void disconnect(String namespace) {
    if (_sockets.containsKey(namespace)) {
      _sockets[namespace]?.disconnect();
      _sockets.remove(namespace);
    }
  }

  /// Disconnects all active socket connections.
  void dispose() {
    for (final socket in _sockets.values) {
      socket.disconnect();
    }
    _sockets.clear();
  }
}
