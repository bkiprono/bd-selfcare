import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

void main() {
  runApp(const BillingApp());
}

class BillingApp extends StatelessWidget {
  const BillingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Billing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFC5C5C5),
        fontFamily: 'SF Pro Display',
      ),
      home: const BillingScreen(),
    );
  }
}

class Invoice {
  final String id;
  final String amount;
  final String status;
  final String email;
  final String invoiceNumber;
  final String displayNumber;
  final String subject;
  final String createdAt;
  final String lastUpdated;
  final String paymentDate;
  final String note;

  Invoice({
    required this.id,
    required this.amount,
    required this.status,
    required this.email,
    required this.invoiceNumber,
    required this.displayNumber,
    required this.subject,
    required this.createdAt,
    required this.lastUpdated,
    required this.paymentDate,
    required this.note,
  });
}

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final Map<String, bool> _expandedItems = {};
  // ignore: unused_field
  Invoice? _selectedInvoice;

  final List<Invoice> invoices = [
    Invoice(
      id: '1',
      amount: '4,500 USD',
      status: 'Paid',
      email: 'Aracely_Hirthe66@gmail.com',
      invoiceNumber: 'INV0938-09-001',
      displayNumber: 'INV4257-09-011',
      subject: 'Service payment batch Sept 2023',
      createdAt: 'Aug 31, 2023 03:47 PM',
      lastUpdated: 'Sep 2, 2023 02:29 AM',
      paymentDate: 'Paid at 25 Jan 2023',
      note: 'Please ensure payment is made by the due date to avoid any late fees.',
    ),
    Invoice(
      id: '2',
      amount: '50 CAD',
      status: 'Past due',
      email: 'Ambrose.Von@hotmail.com',
      invoiceNumber: 'INV0939-09-002',
      displayNumber: 'INV4258-09-012',
      subject: 'Consulting services',
      createdAt: 'Sep 1, 2023 10:15 AM',
      lastUpdated: 'Sep 5, 2023 04:20 PM',
      paymentDate: 'Due Sep 15, 2023',
      note: 'Payment overdue. Please settle immediately.',
    ),
    Invoice(
      id: '3',
      amount: '1,000,000 JPY',
      status: 'Draft',
      email: 'Ruby14@hotmail.com',
      invoiceNumber: 'INV0940-09-003',
      displayNumber: 'INV4259-09-013',
      subject: 'Annual contract',
      createdAt: 'Sep 3, 2023 02:30 PM',
      lastUpdated: 'Sep 3, 2023 02:30 PM',
      paymentDate: 'Not sent',
      note: 'Draft invoice pending review.',
    ),
  ];

  void _toggleExpand(String id) {
    setState(() {
      _expandedItems[id] = !(_expandedItems[id] ?? false);
    });
  }

  void _showInvoiceDetail(Invoice invoice) {
    setState(() {
      _selectedInvoice = invoice;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InvoiceDetailSheet(
        invoice: invoice,
        onClose: () {
          Navigator.pop(context);
          setState(() {
            _selectedInvoice = null;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC5C5C5),
      body: SafeArea(
        child: Center(
          child: Container(
            width: 390,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Status Bar
                _buildStatusBar(),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, size: 24, color: Colors.black),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Billing',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Tabs
                            Row(
                              children: [
                                _buildTab('Overview', true),
                                const SizedBox(width: 8),
                                _buildTab('Quotation', false),
                                const SizedBox(width: 8),
                                _buildTab('Invoice', false),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Search & Filter
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFFE5E5E5)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      children: [
                                        SizedBox(width: 12),
                                        HugeIcon(
                                          icon: HugeIcons.strokeRoundedSearch01,
                                          size: 18,
                                          color: Color(0xFF999999),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: TextField(
                                            decoration: InputDecoration(
                                              hintText: 'Search',
                                              hintStyle: TextStyle(
                                                color: Color(0xFF999999),
                                                fontSize: 16,
                                              ),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  height: 44,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFE5E5E5)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedFilterHorizontal,
                                        size: 18,
                                        color: Color(0xFF666666),
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Filter',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Invoice List
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: invoices.length,
                          itemBuilder: (context, index) {
                            return InvoiceCard(
                              invoice: invoices[index],
                              isExpanded: _expandedItems[invoices[index].id] ?? false,
                              onToggle: () => _toggleExpand(invoices[index].id),
                              onTap: () => _showInvoiceDetail(invoices[index]),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Home Indicator
                Container(
                  height: 34,
                  alignment: Alignment.center,
                  child: Container(
                    width: 134,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '9:41',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          Row(
            children: [
              HugeIcon(icon: HugeIcons.strokeRoundedSignal, size: 16, color: Colors.black),
              SizedBox(width: 5),
              HugeIcon(icon: HugeIcons.strokeRoundedWifi01, size: 16, color: Colors.black),
              SizedBox(width: 5),
              HugeIcon(icon: HugeIcons.strokeRoundedBaby01, size: 24, color: Colors.black),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF0F0F0) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isActive ? Colors.black : const Color(0xFF666666),
        ),
      ),
    );
  }
}

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.isExpanded,
    required this.onToggle,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return const Color(0xFFD1FAE5);
      case 'Past due':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Paid':
        return const Color(0xFF059669);
      case 'Past due':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E5E5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              invoice.amount,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(invoice.status),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                invoice.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _getStatusTextColor(invoice.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          invoice.email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedMoreVertical,
                    size: 20,
                    color: Color(0xFF999999),
                  ),
                  IconButton(
                    icon: HugeIcon(
                      icon: isExpanded
                          ? HugeIcons.strokeRoundedArrowUp01
                          : HugeIcons.strokeRoundedArrowDown01,
                      size: 20,
                      color: const Color(0xFF999999),
                    ),
                    onPressed: onToggle,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('INVOICE NUMBER', invoice.invoiceNumber),
                  const SizedBox(height: 12),
                  _buildDetailRow('SUBJECT', invoice.subject),
                  const SizedBox(height: 12),
                  _buildDetailRow('CREATED AT', invoice.createdAt),
                  const SizedBox(height: 12),
                  _buildDetailRow('LAST UPDATED', invoice.lastUpdated),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class InvoiceDetailSheet extends StatefulWidget {
  final Invoice invoice;
  final VoidCallback onClose;

  const InvoiceDetailSheet({
    super.key,
    required this.invoice,
    required this.onClose,
  });

  @override
  State<InvoiceDetailSheet> createState() => _InvoiceDetailSheetState();
}

class _InvoiceDetailSheetState extends State<InvoiceDetailSheet> {
  String _activeTab = 'Details';

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return const Color(0xFFD1FAE5);
      case 'Past due':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Paid':
        return const Color(0xFF059669);
      case 'Past due':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header with close button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    size: 20,
                    color: Color(0xFF666666),
                  ),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          // Invoice Icon
          SizedBox(
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 64,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 150,
                  child: Container(
                    width: 56,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE5E5E5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFBFDBFE),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 30,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            margin: const EdgeInsets.only(right: 4, bottom: 4),
                            width: 32,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const HugeIcon(
                              icon: HugeIcons.strokeRoundedDollar01,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Amount
          const SizedBox(height: 16),
          Text(
            widget.invoice.amount,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No. ${widget.invoice.displayNumber}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),

          // Status & Payment Date
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              border: Border.symmetric(
                horizontal: BorderSide(color: Color(0xFFE5E5E5)),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(widget.invoice.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.invoice.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getStatusTextColor(widget.invoice.status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Payment Date',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                    Text(
                      widget.invoice.paymentDate,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E5E5)),
              ),
            ),
            child: Row(
              children: [
                _buildTabButton('Details'),
                _buildTabButton('Activity Log'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _activeTab == 'Details'
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Note',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.invoice.note,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Log',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Invoice was sent to',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Created',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.invoice.createdAt,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Last Updated',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.invoice.lastUpdated,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFE5E5E5)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedSent, size: 18, color: Color(0xFF374151)),
                    label: const Text('Send Invoice'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      foregroundColor: const Color(0xFF374151),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedDownload01, size: 18, color: Color(0xFF374151)),
                    label: const Text('Export'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      foregroundColor: const Color(0xFF374151),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label) {
    final isActive = _activeTab == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? const Color(0xFF2563EB) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isActive ? const Color(0xFF2563EB) : const Color(0xFF666666),
            ),
          ),
        ),
      ),
    );
  }
}