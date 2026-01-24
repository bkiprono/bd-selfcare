import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdoneapp/providers/providers.dart';
import 'package:bdoneapp/providers/currencies/currency_list_provider.dart';
import 'package:bdoneapp/models/common/invoice.dart';
import 'package:bdoneapp/components/shared/date_text.dart';
import 'package:bdoneapp/components/shared/header.dart';
import 'package:intl/intl.dart';
import 'package:bdoneapp/components/logger_config.dart';

class PaybillScreen extends ConsumerStatefulWidget {
  final String invoiceId;
  const PaybillScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<PaybillScreen> createState() => _PaybillScreenState();
}

class _PaybillScreenState extends ConsumerState<PaybillScreen> {
  final TextEditingController _phoneController = TextEditingController();
  late String invoiceId;
  Invoice? _invoice;
  bool _isLoading = true;
  String _formattedAmountKES = '0.00';

  // You can set these as constants or fetch from config/service if needed
  static const String _paybillNumber = '123456'; // Replace with actual paybill
  String get _accountNumber => _invoice?.serial ?? '';

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
      });

      await _convertAmountToKES();
      logger.d('Invoice amount: ${invoice.amountDue}');
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
    super.dispose();
  }

  /// Converts the invoice amount to KES and formats it for display.
  Future<void> _convertAmountToKES() async {
    if (_invoice == null) return;

    try {
      final currencyService = ref.read(currencyServiceProvider);
      final kesCurrency = await currencyService.fetchCurrencyByCode('KES');

      if (kesCurrency != null) {
        final sourceCurrency = currencyService.getCurrencyById(
          _invoice?.currencyId ?? '',
        );

        if (sourceCurrency != null) {
          await currencyService.setCurrency(kesCurrency);
          final convertedAmount = currencyService.convertAmount(
            _invoice?.amountDue ?? 0.0,
            currencyId: sourceCurrency.code,
          );

          final formatter = NumberFormat.currency(
            locale: 'en_KE',
            symbol: 'KES ',
            decimalDigits: 2,
          );

          final formattedAmount = formatter.format(convertedAmount);

          setState(() {
            _formattedAmountKES = formattedAmount;
          });
        } else {
          final formatter = NumberFormat.currency(
            locale: 'en_KE',
            symbol: 'KES ',
            decimalDigits: 2,
          );
          final formattedAmount = formatter.format(_invoice?.amountDue ?? 0.0);

          setState(() {
            _formattedAmountKES = formattedAmount;
          });
        }
      } else {
        final formatter = NumberFormat.currency(
          locale: 'en_KE',
          symbol: 'KES ',
          decimalDigits: 2,
        );
        final formattedAmount = formatter.format(_invoice?.amountDue ?? 0.0);

        setState(() {
          _formattedAmountKES = formattedAmount;
        });
      }
    } catch (e, s) {
      logger.e('Error formatting amount', error: e, stackTrace: s);
      setState(() {
        _formattedAmountKES = (_invoice?.amountDue ?? 0.0).toStringAsFixed(2);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _invoice == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        appBar: Header(
          title: 'Pay to Paybill',
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
                    _formattedAmountKES,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DateText(date: _invoice?.dueDate ?? DateTime.now()),
              const SizedBox(height: 32),
              _buildDetailRow('To', _invoice?.client.name ?? ''),
              const SizedBox(height: 12),
              _buildDetailRow('Phone', _invoice?.client.phone ?? ''),
              const SizedBox(height: 12),
              _buildDetailRow('Invoice', _invoice?.serial ?? ''),
              const SizedBox(height: 32),
              const Text(
                'How to pay via M-PESA Paybill',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1. Go to M-PESA on your phone',
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '2. Select Lipa na M-PESA, then Paybill',
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '3. Enter Paybill Number: ',
                          style: TextStyle(fontSize: 15),
                        ),
                        SelectableText(
                          _paybillNumber,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '4. Enter Account Number: ',
                          style: TextStyle(fontSize: 15),
                        ),
                        SelectableText(
                          _accountNumber,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '5. Enter Amount: $_formattedAmountKES',
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '6. Enter your M-PESA PIN and confirm',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Number (optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.phone_android,
                                color: Colors.green[700],
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '+254',
                                style: TextStyle(
                                  color: Colors.green[700],
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
                            color: Colors.green,
                            width: 1.8,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                      ),
                      maxLength: 9,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Optionally, you can implement a callback to confirm payment or notify admin
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please complete the payment via M-PESA Paybill.',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'I have paid $_formattedAmountKES',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'By confirming your payment, you allow Pedea to process your payment and save your payment information in accordance with their terms.',
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
