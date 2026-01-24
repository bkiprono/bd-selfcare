import 'package:flutter/material.dart';
import 'package:bdoneapp/screens/no_internet.dart';
import 'package:bdoneapp/services/connectivity_service.dart';
import 'package:bdoneapp/components/widgets/initialization-widget.dart';

class AppWrapper extends StatefulWidget {
  final Widget child;
  const AppWrapper({super.key, required this.child});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  late final ConnectivityService _connectivityService;
  late final Stream<bool> _connectionStream;

  @override
  void initState() {
    super.initState();
    _connectivityService = ConnectivityService();
    _connectionStream = _connectivityService.connectionStream;
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  void _retryConnection() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _connectionStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const InitializationWidget();
        }

        final isOnline = snapshot.data ?? true;

        if (!isOnline) {
          return NoInternetScreen(onRetry: _retryConnection);
        }

        return widget.child;
      },
    );
  }
}
