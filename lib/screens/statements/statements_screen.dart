import 'package:bdoneapp/core/styles.dart';
import 'package:bdoneapp/models/common/statement.dart';
import 'package:bdoneapp/providers/statements_provider.dart';
import 'package:bdoneapp/screens/statements/request_statement_bottom_sheet.dart';
import 'package:bdoneapp/screens/statements/statement_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class StatementsScreen extends ConsumerStatefulWidget {
  const StatementsScreen({super.key});

  @override
  ConsumerState<StatementsScreen> createState() => _StatementsScreenState();
}

class _StatementsScreenState extends ConsumerState<StatementsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch statements on init
    Future.microtask(() => ref.read(statementsProvider.notifier).fetchStatements(refresh: true));
  }

  Future<void> _onRefresh() async {
    await ref.read(statementsProvider.notifier).refresh();
  }

  void _requestStatement() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RequestStatementBottomSheet(),
    ).then((result) {
      if (result == true) {
        // Refresh the list after successful statement request
        _onRefresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final statementsState = ref.watch(statementsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Statements',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: _requestStatement,
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedFileAdd,
                size: 18,
                color: AppColors.primary,
              ),
              label: const Text(
                'Request',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        backgroundColor: Colors.white,
        child: statementsState.isLoading && statementsState.statements.isEmpty
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : statementsState.statements.isEmpty
                ? _buildEmptyState()
                : _buildStatementsList(statementsState.statements),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const HugeIcon(
              icon: HugeIcons.strokeRoundedFileDownload,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No statements yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Request your first statement to get started',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _requestStatement,
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedFileAdd,
              size: 18,
              color: Colors.white,
            ),
            label: const Text('Request Statement'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatementsList(List<Statement> statements) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: statements.length,
      itemBuilder: (context, index) {
        final statement = statements[index];
        return _buildStatementCard(statement);
      },
    );
  }

  Widget _buildStatementCard(Statement statement) {
    final formatter = DateFormat('dd MMM yyyy');
    final statusColor = _getStatusColor(statement.status);
    final statusIcon = _getStatusIcon(statement.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StatementDetailScreen(
                  statementId: statement.id,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const HugeIcon(
                        icon: HugeIcons.strokeRoundedFileDownload,
                        size: 24,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statement.statementNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${formatter.format(statement.startDate)} - ${formatter.format(statement.endDate)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HugeIcon(
                            icon: statusIcon,
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statement.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedCalendar03,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Generated on ${formatter.format(statement.createdAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'GENERATED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'FAILED':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  dynamic _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'GENERATED':
        return HugeIcons.strokeRoundedCheckmarkCircle02;
      case 'PENDING':
        return HugeIcons.strokeRoundedClock01;
      case 'FAILED':
        return HugeIcons.strokeRoundedCancelCircle;
      default:
        return HugeIcons.strokeRoundedInformationCircle;
    }
  }
}
