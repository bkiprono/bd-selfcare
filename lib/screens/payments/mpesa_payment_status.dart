import 'package:bdoneapp/core/socket/topics.dart';
import 'package:bdoneapp/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdoneapp/components/logger_config.dart';
import 'package:bdoneapp/core/styles.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class MpesaPaymentStatusScreen extends ConsumerStatefulWidget {
  final String checkoutRequestID;
  final String orderId;

  const MpesaPaymentStatusScreen({
    super.key,
    required this.checkoutRequestID,
    required this.orderId,
  });

  @override
  ConsumerState<MpesaPaymentStatusScreen> createState() =>
      _MpesaPaymentStatusScreenState();
}

class _MpesaPaymentStatusScreenState extends ConsumerState<MpesaPaymentStatusScreen> {
  bool _paymentReceived = false;
  bool _isLoading = false;
  bool _isPolling = false;
  StreamSubscription? _socketSubscription;

  @override
  void initState() {
    super.initState();
    _initSocket();
    _checkPaymentStatus(withPolling: true);
  }

  void _initSocket() {
    final socketService = ref.read(socketServiceProvider);
    if (socketService == null) {
      logger.w('Socket service not available');
      return;
    }

    // Connect to /mpesa namespace and listen for mpesaTransactionResponse
    _socketSubscription = socketService
        .onEvent('/mpesa', SocketIoTopics.mpesaTransactionResponse.value)
        .listen((data) {
      logger.i('Received socket response: $data');
      if (data != null && data is Map) {
        final checkoutId = data['data'];
        final statusCode = data['statusCode'];

        if (checkoutId == widget.checkoutRequestID && statusCode == 200) {
          if (mounted) {
            setState(() {
              _paymentReceived = true;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }

  /// Poll payment status if [withPolling] is true.
  Future<void> _checkPaymentStatus({bool withPolling = false}) async {
    setState(() {
      _isLoading = true;
    });

    final paymentService = ref.read(paymentServiceProvider);
    bool received = false;

    Future<bool> fetchStatusOnce() async {
      try {
        final response = await paymentService.getMpesaPaymentStatus(
          widget.checkoutRequestID,
        );
        // Consider payment received if status == 'done'.
        logger.d('Mpesa status response: $response');
        if (response != null &&
            response['status'] != null &&
            response['status'].toString().toLowerCase() == 'done') {
          if (!mounted) return true;
          setState(() {
            _paymentReceived = true;
          });
          return true;
        }
      } catch (e) {
        // Optionally handle individual error, e.g., show a message or log.
      }
      return false;
    }

    if (withPolling) {
      setState(() {
        _isPolling = true;
      });
      while (!received && mounted && !_paymentReceived) {
        received = await fetchStatusOnce();
        if (received) break;
        await Future.delayed(const Duration(seconds: 3));
      }
      if (!mounted) return;
      setState(() {
        _isPolling = false;
        _isLoading = false;
      });
    } else {
      received = await fetchStatusOnce();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    // Only refresh if not polling.
    if (!_isPolling) {
      await _checkPaymentStatus(withPolling: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'MPESA Payment Status',
          style: TextStyle(
            color: Color(0xFF232323),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF10B981)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        displacement: 40,
        edgeOffset: 60,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height -
                kToolbarHeight -
                MediaQuery.of(context).padding.top -
                (MediaQuery.of(context).padding.bottom),
            child: Center(
              child: _paymentReceived
                  ? _buildSuccessContent()
                  : _buildLoaderContent(),
            ),
          ),
        ),
      ),
      bottomNavigationBar: !_paymentReceived
          ? null
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedHome01,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Go Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLoaderContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildMpesaLogo(size: 84),
        const SizedBox(height: 32),
        _isLoading
            ? const CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF10B981),
              )
            : Icon(Icons.refresh, color: Colors.grey[400], size: 40),
        const SizedBox(height: 24),
        const Text(
          'Waiting for Payment Confirmation...',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF16A34A),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: Color(0xFF374151)),
            children: [
              const TextSpan(text: "We're verifying your payment for order:\n"),
              TextSpan(
                text: widget.checkoutRequestID,
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Do NOT leave this page until payment is confirmed.',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFFD97706),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        if (!_isPolling)
          Text(
            'Pull down to try again.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildMpesaLogo(size: 120),
        const SizedBox(height: 32),
        const HugeIcon(
          icon: HugeIcons.strokeRoundedCheckmarkBadge03,
          color: Colors.green,
          size: 120,
        ),
        const SizedBox(height: 24),
        const Text(
          'Payment Received',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF10B981),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Thank you! Your payment has been confirmed successfully.',
          style: TextStyle(fontSize: 14, color: Color(0xFF065F46)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.green,
            border: Border.all(color: Colors.green),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Order Reference: ${widget.checkoutRequestID}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildMpesaLogo({double size = 60}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.2),
      child: Image.asset(
        'assets/icons/mpesa.png',
        width: size * 0.8,
        height: size * 0.8,
        fit: BoxFit.contain,
      ),
    );
  }
}
