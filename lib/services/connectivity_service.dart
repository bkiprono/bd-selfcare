import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// service for monitoring network connectivity status.
/// Provides a broadcast stream of [bool], where `true` means online.
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  bool? _lastStatus;
  bool _isDisposed = false;
  Timer? _debounceTimer;
  Timer? _recheckTimer;

  ConnectivityService() {
    // Listen to connectivity changes and emit only when status changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
    _initCheck();
  }

  // Handle connectivity change, only add if status changed
  void _onConnectivityChanged(List<ConnectivityResult> results) async {
    final hasNetwork = _hasNetworkConnection(results);

    if (hasNetwork) {
      // If we have network, check if we have actual internet access
      final isOnline = await _hasActualInternetAccess();
      _handleStatusChange(isOnline);
    } else {
      // No network - use debounce to avoid flickering during handover
      _debounceOfflineStatus();
    }
  }

  // Check if any of the results indicate a network connection
  bool _hasNetworkConnection(List<ConnectivityResult> results) {
    return results.isNotEmpty &&
        !results.every((result) => result == ConnectivityResult.none);
  }

  // Real internet check via lookup
  Future<bool> _hasActualInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // Use a short delay before confirming offline status to avoid flickering
  void _debounceOfflineStatus() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      _handleStatusChange(false);
    });
  }

  void _handleStatusChange(bool isOnline) {
    if (isOnline) {
      _debounceTimer?.cancel();
      _recheckTimer?.cancel();
      _recheckTimer = null;
    } else {
      // If offline, start a recheck timer to poll for internet restoration
      if (_recheckTimer == null || !_recheckTimer!.isActive) {
        _recheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
          // Check if plugin reports network interface is up
          final results = await _connectivity.checkConnectivity();
          if (_hasNetworkConnection(results)) {
            final hasAccess = await _hasActualInternetAccess();
            if (hasAccess) {
              _handleStatusChange(true);
            }
          }
        });
      }
    }

    if (_lastStatus == null || _lastStatus != isOnline) {
      _lastStatus = isOnline;
      _safeAdd(isOnline);
    }
  }

  // Initial check on construction
  Future<void> _initCheck() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final hasNetwork = _hasNetworkConnection(results);
      if (hasNetwork) {
        final isOnline = await _hasActualInternetAccess();
        _handleStatusChange(isOnline);
      } else {
        _handleStatusChange(false);
      }
    } catch (e) {
      _handleStatusChange(false);
    }
  }

  void _safeAdd(bool value) {
    if (!_isDisposed && !_controller.isClosed) {
      _controller.sink.add(value);
    }
  }

  /// Returns a stream of online status.
  /// True = online, false = offline.
  Stream<bool> get connectionStream => _controller.stream.distinct();

  /// Properly disposes resources. Call this when no longer needed.
  void dispose() {
    _isDisposed = true;
    _debounceTimer?.cancel();
    _recheckTimer?.cancel();
    _subscription.cancel();
    _controller.close();
  }
}
