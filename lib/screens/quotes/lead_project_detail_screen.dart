import 'package:bdoneapp/components/shared/header.dart';
import 'package:bdoneapp/core/styles.dart';
import 'package:bdoneapp/models/common/lead_project.dart';
import 'package:bdoneapp/models/common/quote.dart';
import 'package:bdoneapp/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class LeadProjectDetailScreen extends ConsumerStatefulWidget {
  final LeadProject leadProject;

  const LeadProjectDetailScreen({super.key, required this.leadProject});

  @override
  ConsumerState<LeadProjectDetailScreen> createState() =>
      _LeadProjectDetailScreenState();
}

class _LeadProjectDetailScreenState
    extends ConsumerState<LeadProjectDetailScreen> {
  Quote? _quote;
  bool _isLoadingQuote = false;
  String? _quoteError;
  late bool _hasQuote;

  @override
  void initState() {
    super.initState();
    _hasQuote = widget.leadProject.hasQuote;
    if (_hasQuote) {
      _fetchQuote();
    }
  }

  Future<void> _fetchQuote({bool isRefresh = false}) async {
    setState(() {
      _isLoadingQuote = !isRefresh;
      _quoteError = null;
    });

    try {
      final quoteService = ref.read(quoteServiceProvider);
      // Fetch quotes filtered by lead/client to find the one matching this project
      final result = await quoteService.fetchQuotes(
        leadId: widget.leadProject.leadId,
        clientId: widget.leadProject.clientId,
        limit: 100, // Fetch enough to find ours
      );

      if (result.data != null) {
        try {
          final quote = result.data!.firstWhere(
            (q) => q.leadProjectId == widget.leadProject.id,
          );
          if (mounted) {
            setState(() {
              _quote = quote;
              _hasQuote = true;
            });
          }
        } catch (e) {
          // Quote not found in the list
          if (mounted && _hasQuote) {
            setState(() {
              _quoteError = 'Quote details not found.';
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _quoteError = 'Failed to load quote details.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingQuote = false;
        });
      }
    }
  }

  Future<void> _downloadQuote() async {
    if (_quote?.quoteLink == null) return;

    final Uri url = Uri.parse(_quote!.quoteLink!);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open quote PDF')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const Header(
        title: 'Request Details',
        showProfileIcon: true,
        showCurrencyIcon: false,
        actions: [],
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchQuote(isRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Status Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: _hasQuote
                    ? const Color(0xFFECFDF5) // Green 50
                    : const Color(0xFFFFFBEB), // Amber 50
                child: Row(
                  children: [
                    HugeIcon(
                      icon: _hasQuote
                          ? HugeIcons.strokeRoundedCheckmarkCircle02
                          : HugeIcons.strokeRoundedTime02,
                      size: 20,
                      color: _hasQuote
                          ? const Color(0xFF059669)
                          : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _hasQuote
                          ? 'Quote Prepared'
                          : 'Review In Progress',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _hasQuote
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Request Details Section
                  const Text(
                    'Request Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Title', widget.leadProject.title),
                  _buildDetailRow(
                    'Type',
                    widget.leadProject.projectType.toUpperCase(),
                  ),
                  _buildDetailRow(
                    'Description',
                    widget.leadProject.description,
                  ),
                  _buildDetailRow(
                    'Date',
                    DateFormat(
                      'MMM dd, yyyy',
                    ).format(widget.leadProject.createdAt),
                  ),

                  if (widget.leadProject.features != null &&
                      widget.leadProject.features!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Requested Features',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.leadProject.features!
                          .map(
                            (f) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                f,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 32),

                  // Quote Section
                  if (_hasQuote) ...[
                    const Text(
                      'Quote Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoadingQuote)
                      const Center(child: CircularProgressIndicator())
                    else if (_quoteError != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _quoteError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    else if (_quote != null) ...[
                      _buildQuoteCard(_quote!),
                    ],
                  ] else ...[
                    const Center(
                      child: Column(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedDocumentAttachment,
                            size: 48,
                            color: Color(0xFFE5E7EB),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No quote generated yet',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'We will notify you once expected cost is calculated.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(Quote quote) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Quote Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(
                        symbol: 'KES ',
                      ).format(quote.totalAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    quote.serial,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Quote Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _downloadQuote,
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedDownload01,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    label: const Text('Download PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (quote.items.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Line Items',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            ...quote.items.map(
              (item) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.description ?? '',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      NumberFormat.currency(symbol: '').format(item.total),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
