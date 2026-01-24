import 'package:bdoneapp/components/shared/date_text.dart';
import 'package:bdoneapp/components/shared/full_screen_loader.dart';
import 'package:bdoneapp/core/routes.dart';
import 'package:bdoneapp/core/styles.dart';
import 'package:bdoneapp/models/common/http_response.dart';
import 'package:bdoneapp/models/payments/mpesa_response.dart';
import 'package:bdoneapp/models/payments/pesapal_error.dart';
import 'package:bdoneapp/models/payments/pesapal_response.dart';
import 'package:bdoneapp/models/common/invoice.dart';
import 'package:flutter/material.dart';
import 'package:bdoneapp/components/shared/header.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bdoneapp/components/logger_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdoneapp/providers/providers.dart';
import 'package:bdoneapp/providers/currencies/currency_list_provider.dart';

class InitiatePaymentScreen extends ConsumerStatefulWidget {
  final String invoiceId;
  const InitiatePaymentScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InitiatePaymentScreen> createState() => _InitiatePaymentScreenState();
}

class _InitiatePaymentScreenState extends ConsumerState<InitiatePaymentScreen> {
  String _selectedPaymentMethod = '';
  final TextEditingController _phoneController = TextEditingController();
  late String invoiceId;
  Invoice? _invoice;
  bool _isLoading = true;
  double? _convertedAmount;
  String _formattedAmount = '0.00';
  bool _showPaymentDetails = false;

  bool _processingMpesa = false;
  String? _mpesaErrorMessage;

  bool _processingPesapal = false;
  String? _pesapalErrorMessage;

  bool _payInFull = true;
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    invoiceId = widget.invoiceId;
    _fetchInvoice();
  }

  Future<void> _fetchInvoice() async {
    try {
      final invoiceService = ref.read(invoiceServiceProvider);
      final Invoice invoice = await invoiceService.fetchInvoiceById(
        invoiceId,
      );

      setState(() {
        _invoice = invoice;
        _isLoading = false;
        
        // Pre-fill phone number if available
        if (invoice.client.phone.isNotEmpty) {
          // Extract last 9 digits (format: 7XXXXXXXX)
          final clean = invoice.client.phone.replaceAll(RegExp(r'[^0-9]'), '');
          if (clean.length >= 9) {
            _phoneController.text = clean.substring(clean.length - 9);
          }
        }
      });

      // Format amount based on selected payment method
      await _formatAmountForPaymentMethod();
    } catch (e, s) {
      logger.e('Error fetching invoice', error: e, stackTrace: s);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handlePaymentMethodChange(String method) async {
    setState(() {
      _selectedPaymentMethod = method;
      _showPaymentDetails = true;
      _mpesaErrorMessage = null;
      _pesapalErrorMessage = null;
      _payInFull = true;
      _amountController.text = '';
    });

    // Handle Pesapal payment immediately
    if (method == 'pesapal') {
      // Show payment details briefly before triggering payment
      await Future.delayed(const Duration(milliseconds: 300));
      _submitPesapal();
      return;
    }

    // Re-fetch and format the amount based on the selected payment method
    if (_invoice != null) {
      await _formatAmountForPaymentMethod();
    }
  }

  Future<void> _formatAmountForPaymentMethod() async {
    if (_invoice == null) return;

    try {
      if (_selectedPaymentMethod == 'mpesa') {
        final currencyService = ref.read(currencyServiceProvider);
        final kesCurrency = await currencyService.fetchCurrencyByCode('KES');

        if (kesCurrency != null) {
          final sourceCurrency = currencyService.getCurrencyById(
            _invoice!.currencyId,
          );
          if (sourceCurrency != null) {
            await currencyService.setCurrency(kesCurrency);
            final convertedAmount = currencyService.convertAmount(
              _invoice!.amountDue,
              currencyId: sourceCurrency.code,
            );

            final formatter = NumberFormat.currency(
              locale: 'en_KE',
              symbol: 'KES ',
              decimalDigits: 2,
            );

            final formattedAmount = formatter.format(convertedAmount);

            setState(() {
              _convertedAmount = convertedAmount;
              _formattedAmount = formattedAmount;
              _amountController.text = convertedAmount.toStringAsFixed(2);
            });
          } else {
            final formatter = NumberFormat.currency(
              locale: 'en_KE',
              symbol: 'KES ',
              decimalDigits: 2,
            );
            final formattedAmount = formatter.format(_invoice!.amountDue);

            setState(() {
              _convertedAmount = _invoice!.amountDue;
              _formattedAmount = formattedAmount;
            });
          }
        } else {
          final formatter = NumberFormat.currency(
            locale: 'en_KE',
            symbol: 'KES ',
            decimalDigits: 2,
          );
          final formattedAmount = formatter.format(_invoice!.amountDue);

          setState(() {
            _convertedAmount = _invoice!.amountDue;
            _formattedAmount = formattedAmount;
          });
        }
      } else {
        setState(() {
          _convertedAmount = _invoice!.amountDue;
          _formattedAmount = _invoice!.amountDue.toStringAsFixed(2);
        });
      }
    } catch (e, s) {
      logger.e('Error formatting amount', error: e, stackTrace: s);
      setState(() {
        _convertedAmount = _invoice!.amountDue;
        _formattedAmount = _invoice!.amountDue.toStringAsFixed(2);
      });
    }
  }

  Future<void> _handlePesapalPayment(String pesapalUrl) async {
    try {
      final Uri uri = Uri.parse(pesapalUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e, s) {
      logger.e('Error launching Pesapal payment', error: e, stackTrace: s);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open Pesapal payment. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _validatePhone(String input) {
    final clean = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length != 9) return 'Phone should be 9 digits (7XXXXXXXX or 1XXXXXXXX)';
    if (!(clean.startsWith('7') || clean.startsWith('1'))) {
      return 'Number must start with 7 or 1';
    }
    return null;
  }

  Future<void> _submitMpesa() async {
    FocusScope.of(context).unfocus();

    final input = _phoneController.text.trim();
    final error = _validatePhone(input);
    if (error != null) {
      setState(() {
        _mpesaErrorMessage = error;
      });
      return;
    }

    setState(() {
      _processingMpesa = true;
      _mpesaErrorMessage = null;
    });

    double? customAmount;
    if (!_payInFull) {
      final amountStr = _amountController.text.trim();
      if (amountStr.isEmpty) {
        setState(() {
          _mpesaErrorMessage = 'Please enter an amount';
          _processingMpesa = false;
        });
        return;
      }
      customAmount = double.tryParse(amountStr);
      if (customAmount == null || customAmount <= 0) {
        setState(() {
          _mpesaErrorMessage = 'Please enter a valid amount';
          _processingMpesa = false;
        });
        return;
      }
      if (customAmount > (_convertedAmount ?? 0)) {
        setState(() {
          _mpesaErrorMessage = 'Amount exceeds balance due';
          _processingMpesa = false;
        });
        return;
      }
    }

    // Show full screen loader
    FullScreenLoader.show(
      context,
      title: 'Processing Payment',
      subtitle: 'Please wait while we process your MPESA payment...',
    );

    // Compose full phone
    final fullPhone = '254${input.replaceAll(RegExp(r'[^0-9]'), '')}';

    try {
      // Production-ready call with robust validation and error handling
      final paymentService = ref.read(paymentServiceProvider);
      final Map<String, dynamic> request =
          await paymentService.payWithMpesa(invoiceId, fullPhone, amount: customAmount)
              as Map<String, dynamic>;
      final CustomHttpResponse<MpesaStkResponse> result =
          CustomHttpResponse.fromJson(
            request,
            (data) => MpesaStkResponse.fromJson(data),
          );
      final message = result.message;

      // Hide loader first
      if (mounted) {
        FullScreenLoader.hide(context);
      }

      // Handle response
      if (result.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green[700],
            ),
          );
          logger.i('MPESA payment successful ${result.data.merchantRequestID}');
          // Optionally, navigate or refresh; for now, we just end process
          Navigator.pushNamed(
            context,
            AppRoutes.mpesaPaymentStatus,
            arguments: {
              'checkoutRequestID': result.data.checkoutRequestID,
              'orderId': _invoice!.id,
            },
          );
        }
      } else {
        setState(() {
          _mpesaErrorMessage = result.message;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_mpesaErrorMessage ?? 'Error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e, s) {
      logger.e('MPESA error', error: e, stackTrace: s);
      // Hide loader on error
      if (mounted) {
        FullScreenLoader.hide(context);
      }

      setState(() {
        _mpesaErrorMessage =
            'Network or server error. Please check connection and try again.';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_mpesaErrorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processingMpesa = false;
        });
      }
    }
  }

  Future<void> _submitPesapal() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _processingPesapal = true;
      _pesapalErrorMessage = null;
    });

    // Show full screen loader
    FullScreenLoader.show(
      context,
      title: 'Processing Payment',
      subtitle: 'Please wait while we prepare your Pesapal payment...',
    );

    try {
      // Production-ready call with robust validation and error handling
      final paymentService = ref.read(paymentServiceProvider);
      final Map<String, dynamic> request =
          await paymentService.payWithPesapal(invoiceId)
              as Map<String, dynamic>;

      final CustomHttpResponse<dynamic> result = CustomHttpResponse.fromJson(
        request,
        (data) => data,
      );
      // Hide loader first
      if (mounted) {
        FullScreenLoader.hide(context);
      }
      final int statusCode = result.statusCode;
      final data = result.data;

      if (data is PesapalError) {
        setState(() {
          _pesapalErrorMessage = data.message;
        });
      }

      // Handle response
      if (statusCode == 200 || statusCode == 201) {
        if (mounted) {
          final PesapalResponse data = PesapalResponse.fromJson(result.data);
          final pesapalUrl = data.redirectUrl;

          // Show success message briefly before redirecting
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Payment request successful. Redirecting to Pesapal...',
              ),
              backgroundColor: Colors.green[700],
              duration: const Duration(seconds: 2),
            ),
          );

          // Redirect to Pesapal
          _handlePesapalPayment(pesapalUrl);
        }
      } else {
        setState(() {
          _pesapalErrorMessage = result.message;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_pesapalErrorMessage ?? 'Error processing payment'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e, s) {
      logger.e('PESAPAL error', error: e, stackTrace: s);

      // Hide loader on error
      if (mounted) {
        FullScreenLoader.hide(context);
      }

      setState(() {
        _pesapalErrorMessage =
            'Network or server error. Please check connection and try again.';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_pesapalErrorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processingPesapal = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _invoice == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        appBar: Header(
          title: 'Pay',
          showCurrencyIcon: false,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const Header(
        title: 'Pay',
        showCurrencyIcon: false,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchInvoice,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedPaymentMethod == 'mpesa'
                        ? _formattedAmount
                        : 'KES ${_invoice!.amountDue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DateText(date: _invoice!.dueDate),
              const SizedBox(height: 32),
              _buildDetailRow('To', _invoice!.client.name),
              const SizedBox(height: 12),
              _buildDetailRow('Phone', _invoice!.client.phone),
              const SizedBox(height: 12),
              _buildDetailRow('Invoice', _invoice?.serial ?? ''),
              const SizedBox(height: 32),
              const Text(
                'Choose payment method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _processingMpesa
                    ? null
                    : () {
                        _handlePaymentMethodChange('mpesa');
                      },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedPaymentMethod == 'mpesa'
                          ? Colors.green
                          : Colors.grey[300]!,
                      width: _selectedPaymentMethod == 'mpesa' ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: _processingMpesa ? Colors.grey[50] : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedPaymentMethod == 'mpesa'
                                ? Colors.green
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                          color: _selectedPaymentMethod == 'mpesa'
                              ? Colors.green
                              : Colors.transparent,
                        ),
                        child: _selectedPaymentMethod == 'mpesa'
                            ? (_processingMpesa
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ))
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Image.asset(
                        'assets/icons/mpesa.png',
                        height: 20,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'M-PESA',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _processingMpesa ? 'Processing...' : 'MPESA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _processingMpesa
                              ? Colors.grey[600]
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_mpesaErrorMessage != null && _mpesaErrorMessage!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[700], size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _mpesaErrorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              if (_showPaymentDetails && _selectedPaymentMethod == 'mpesa') ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _processingMpesa
                        ? Colors.orange[50]
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: _processingMpesa
                        ? Border.all(color: Colors.orange[200]!)
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Amount Type Selection
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _payInFull = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: _payInFull ? Colors.green.withValues(alpha:0.1) : Colors.transparent,
                                  border: Border.all(color: _payInFull ? Colors.green : Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    'Full Amount',
                                    style: TextStyle(
                                      color: _payInFull ? Colors.green[700] : Colors.grey[600],
                                      fontWeight: _payInFull ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _payInFull = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: !_payInFull ? Colors.green.withValues(alpha:0.1) : Colors.transparent,
                                  border: Border.all(color: !_payInFull ? Colors.green : Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    'Custom Amount',
                                    style: TextStyle(
                                      color: !_payInFull ? Colors.green[700] : Colors.grey[600],
                                      fontWeight: !_payInFull ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (!_payInFull) ...[
                        Text(
                          'Amount to Pay',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          enabled: !_processingMpesa,
                          decoration: InputDecoration(
                            prefixIcon: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('KES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                            hintText: 'Enter amount',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.secondary, width: 1.8),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Row(
                        children: [
                          Icon(
                            _processingMpesa
                                ? Icons.hourglass_empty
                                : Icons.phone_android,
                            color: _processingMpesa
                                ? Colors.orange[700]
                                : Colors.grey[700],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _processingMpesa
                                ? 'Processing Payment'
                                : 'Payment Number',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _processingMpesa
                                  ? Colors.orange[700]
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      if (_processingMpesa) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Please wait while we process your MPESA payment...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          color: Colors.orange[700],
                          backgroundColor: Colors.orange[100],
                        ),
                        const SizedBox(height: 16),
                      ] else
                        const SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        enabled: !_processingMpesa,
                        decoration: InputDecoration(
                          prefixIcon: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.phone_android,
                                  color: AppColors.secondary,
                                  size: 20,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '+254',
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                          hintText: '7XXXXXXXX',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 15,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.secondary,
                              width: 1.8,
                            ),
                          ),
                          errorText: null, // Move error display to below
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.0,
                        ),
                        maxLength: 9,
                        onChanged: (_) {
                          setState(() {
                            _mpesaErrorMessage = null;
                          });
                        },
                        onSubmitted: (_) {
                          if (!_processingMpesa) _submitMpesa();
                        },
                      ),
                      if (_mpesaErrorMessage != null &&
                          _mpesaErrorMessage!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error,
                                color: AppColors.error,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _mpesaErrorMessage!,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _processingMpesa ? null : _submitMpesa,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _processingMpesa
                          ? AppColors.border
                          : AppColors.secondary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _processingMpesa
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Initiate Payment of ${_payInFull ? _formattedAmount : 'KES ${_amountController.text}'}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_showPaymentDetails &&
                  _selectedPaymentMethod == 'pesapal') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _processingPesapal
                        ? Colors.orange[50]
                        : Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _processingPesapal
                          ? Colors.orange[200]!
                          : Colors.blue[200]!,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _processingPesapal
                                ? Icons.hourglass_empty
                                : Icons.info_outline,
                            color: _processingPesapal
                                ? Colors.orange[700]
                                : Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _processingPesapal
                                ? 'Processing Payment'
                                : 'Pesapal Payment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _processingPesapal
                                  ? Colors.orange[700]
                                  : Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _processingPesapal
                            ? 'Please wait while we process your payment request...'
                            : 'You will be redirected to Pesapal to complete your payment securely.',
                        style: TextStyle(
                          fontSize: 14,
                          color: _processingPesapal
                              ? Colors.orange[600]
                              : Colors.blue[600],
                        ),
                      ),
                      if (_processingPesapal) ...[
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          color: Colors.orange[700],
                          backgroundColor: Colors.orange[100],
                        ),
                      ],
                      if (_pesapalErrorMessage != null &&
                          _pesapalErrorMessage!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error,
                                color: Colors.red[700],
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _pesapalErrorMessage!,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (_pesapalErrorMessage != null &&
                  _pesapalErrorMessage!.isNotEmpty &&
                  (!_showPaymentDetails || _selectedPaymentMethod != 'pesapal'))
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[700], size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _pesapalErrorMessage!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _processingPesapal
                    ? null
                    : () {
                        _handlePaymentMethodChange('pesapal');
                      },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedPaymentMethod == 'pesapal'
                          ? AppColors.secondary
                          : AppColors.border,
                      width: _selectedPaymentMethod == 'pesapal' ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: _processingPesapal ? Colors.grey[50] : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedPaymentMethod == 'pesapal'
                                ? AppColors.secondary
                                : AppColors.border,
                            width: 2,
                          ),
                          color: _selectedPaymentMethod == 'pesapal'
                              ? AppColors.secondary
                              : Colors.transparent,
                        ),
                        child: _selectedPaymentMethod == 'pesapal'
                            ? (_processingPesapal
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    ))
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Image.asset(
                        'assets/icons/pesapal.png',
                        height: 20,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Pesapal',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _processingPesapal ? 'Processing...' : 'Pesapal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _processingPesapal
                              ? Colors.grey[600]
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'By confirming your payment, you allow Pedea to charge you for this payment and save your payment information in accordance with their terms.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
