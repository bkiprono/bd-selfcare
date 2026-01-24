import 'package:bdoneapp/components/shared/header.dart';
import 'package:bdoneapp/core/styles.dart';
import 'package:bdoneapp/models/common/support_request.dart';
import 'package:bdoneapp/screens/help/create_support_ticket_sheet.dart';
import 'package:bdoneapp/providers/support_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateTicketSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateSupportTicketSheet(
        onSuccess: () {
          ref.read(supportProvider.notifier).refresh();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supportProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const Header(
        title: 'Support',
        showProfileIcon: true,
        showCurrencyIcon: false,
        actions: [],
      ),
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E5E5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedSearch01,
                          size: 18,
                          color: Color(0xFF999999),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search tickets...',
                              hintStyle: TextStyle(
                                color: Color(0xFF999999),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (val) {
                              ref.read(supportProvider.notifier).setKeyword(val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _showCreateTicketSheet,
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedAdd01,
                    size: 24,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: state.isLoading && state.supportRequests.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.error != null && state.supportRequests.isEmpty
                    ? Center(child: Text(state.error!))
                    : RefreshIndicator(
                        onRefresh: () => ref.read(supportProvider.notifier).refresh(),
                        child: state.supportRequests.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: state.supportRequests.length +
                                    (state.page <= state.totalPages ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == state.supportRequests.length) {
                                    ref.read(supportProvider.notifier).fetchSupportRequests();
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  final ticket = state.supportRequests[index];
                                  return SupportTicketCard(ticket: ticket);
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HugeIcon(
            icon: HugeIcons.strokeRoundedHeadset,
            size: 64,
            color: Color(0xFFE5E7EB),
          ),
          const SizedBox(height: 16),
          Text(
            'No support tickets found',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _showCreateTicketSheet,
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 18),
            label: const Text('Create Ticket'),
          ),
        ],
      ),
    );
  }
}

class SupportTicketCard extends StatelessWidget {
  final SupportRequest ticket;

  const SupportTicketCard({super.key, required this.ticket});

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return const Color(0xFFE0F2FE); // Blue 100
      case 'IN_PROGRESS':
        return const Color(0xFFFEF3C7); // Amber 100
      case 'RESOLVED':
      case 'CLOSED':
        return const Color(0xFFD1FAE5); // Emerald 100
      default:
        return const Color(0xFFF3F4F6); // Gray 100
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return const Color(0xFF0369A1); // Blue 700
      case 'IN_PROGRESS':
        return const Color(0xFFD97706); // Amber 700
      case 'RESOLVED':
      case 'CLOSED':
        return const Color(0xFF059669); // Emerald 700
      default:
        return const Color(0xFF6B7280); // Gray 500
    }
  }

  Color _getPriorityColor(RequestPriorityEnum priority) {
    switch (priority) {
      case RequestPriorityEnum.critical:
      case RequestPriorityEnum.high:
        return Colors.red;
      case RequestPriorityEnum.medium:
        return Colors.orange;
      case RequestPriorityEnum.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: InkWell(
        onTap: () {
          // TODO: View ticket details
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(ticket.status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ticket.status.toUpperCase().replaceAll('_', ' '),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getStatusTextColor(ticket.status),
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(ticket.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ticket.subject,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '#${ticket.ticketNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                      fontFamily: 'Monospace',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD1D5DB),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.flag_rounded,
                    size: 14,
                    color: _getPriorityColor(ticket.priority),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ticket.priority.value.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getPriorityColor(ticket.priority),
                    ),
                  ),
                ],
              ),
              if (ticket.project != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedFolder01,
                      size: 14,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ticket.project!.title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
