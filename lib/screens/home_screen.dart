import 'package:bdoneapp/core/styles.dart';
import 'package:bdoneapp/models/common/base_transaction.dart';
import 'package:bdoneapp/models/common/invoice.dart';
import 'package:bdoneapp/models/payments/payment.dart';
import 'package:bdoneapp/models/auth/auth_state.dart';
import 'package:bdoneapp/models/auth/user_model.dart';
import 'package:bdoneapp/providers/auth_providers.dart';
import 'package:bdoneapp/providers/invoices_provider.dart';
import 'package:bdoneapp/screens/billing/invoices_screen.dart';
import 'package:bdoneapp/providers/home_provider.dart';
import 'package:bdoneapp/providers/payments_provider.dart';
import 'package:bdoneapp/screens/payments/payments_screen.dart';
import 'package:bdoneapp/screens/quotes/lead_projects_screen.dart';
import 'package:bdoneapp/screens/help/support_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      ref.read(authProvider.notifier).refreshProfile(),
      ref.read(invoicesProvider.notifier).refresh(),
      ref.read(paymentsProvider.notifier).refresh(),
    ]);
  }
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState is Authenticated ? authState.user : null;
    final transactions = ref.watch(combinedTransactionsProvider);
    final formatter = NumberFormat('#,##0.00', 'en_US');

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(user),
                  const SizedBox(height: 1),
                  _buildBalanceCard(user, formatter),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 28),
                  _buildRecentTransactions(context, transactions),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(User? user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '✋',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Hello ${user?.name.split(' ')[0] ?? ''},',
                    style: const TextStyle(
                      fontSize: 26,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const Text(
                'Welcome back to BD',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Container(
          //   width: 40,
          //   height: 40,
          //   decoration: BoxDecoration(
          //     color: AppColors.surface,
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(color: AppColors.border),
          //   ),
          //   child: const HugeIcon(
          //     icon: HugeIcons.strokeRoundedNotification02,
          //     size: 20,
          //     color: AppColors.textPrimary,
          //   ),
          // ),
          // const SizedBox(width: 12),
          // Container(
          //   width: 40,
          //   height: 40,
          //   decoration: BoxDecoration(
          //     color: AppColors.surface,
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(color: AppColors.border),
          //   ),
          //   child: const HugeIcon(
          //     icon: HugeIcons.strokeRoundedAiScan,
          //     size: 20,
          //     color: AppColors.textPrimary,
          //   ),
          // ),
          // const SizedBox(width: 12),
          // Container(
          //   width: 32,
          //   height: 32,
          //   decoration: const BoxDecoration(
          //     gradient: LinearGradient(
          //       colors: [AppColors.primary, AppColors.primary700],
          //       begin: Alignment.topLeft,
          //       end: Alignment.bottomRight,
          //     ),
          //     shape: BoxShape.circle,
          //   ),
          //   child: const Center(
          //     child: HugeIcon(
          //       icon: HugeIcons.strokeRoundedAnalytics01,
          //       color: Colors.white,
          //       size: 18,
          //     ),
          //   ),
          // ),
        
        ],
      ),
    );
  }

  Widget _buildBalanceCard(User? user, NumberFormat formatter) {
    var balance = user?.client?.currentBalance ?? 0.0;
    // ensure the balance is positive
    if (balance < 0) {
      balance = balance * -1;
    }
    final balanceString = formatter.format(balance);
    // Split integral and decimal parts for styling
    final parts = balanceString.split('.');
    final integral = parts[0];
    final decimal = parts.length > 1 ? parts[1] : '00';

    // Default account number fallback
    final accountNumber =
        user?.client?.accountNumber ?? user?.client?.serial ?? '*********';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            AppColors.primary900,
            AppColors.primary800,
            AppColors.accent,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha:0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Animated background pattern 1 (Top Right)
            Positioned(
              top: -100,
              left: -100,
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    // Pulse scale between 1.0 and 1.1
                    final pulse = 1.0 + 0.05 * (1 - (2 * _controller.value - 1).abs());

                    return Transform.scale(
                      scale: pulse,
                      child: Transform.rotate(
                        angle: _controller.value * 2 * 3.14159,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha:0.1),
                          Colors.white.withValues(alpha:0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Animated background pattern 2 (Bottom Left)
            Positioned(
              bottom: -80,
              left: -40,
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                     final pulse = 1.0 + 0.08 * (1 - (2 * ((_controller.value + 0.5) % 1.0) - 1).abs());
                    return Transform.scale(
                      scale: pulse,
                      child: Transform.rotate(
                        angle: -_controller.value * 2 * 3.14159,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha:0.08),
                          Colors.white.withValues(alpha:0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Main Image
            Positioned(
              right: -20,
              top: -20,
              bottom: -20,
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const NetworkImage(
                      'https://bdcomputing.co.ke/assets/images/daisy.jpg',
                    ),
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      AppColors.primary.withValues(alpha: 0.3),
                      BlendMode.dstATop,
                    ),
                  ),
                ),
              ),
            ),


            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        accountNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const HugeIcon(
                          icon: HugeIcons.strokeRoundedCopy01,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowUpRight01,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Text(
                        'Client Balance',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 8),
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedView,
                        size: 18,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'KES ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            integral,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                          Text(
                            '.$decimal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Quick actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionItem(
                HugeIcons.strokeRoundedNote01,
                'Quotes',
                AppColors.primary,
                AppColors.accent,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LeadProjectsScreen()),
                ),
              ),
              _buildActionItem(
                HugeIcons.strokeRoundedWallet01,
                'Payments',
                AppColors.primary,
                AppColors.accent,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PaymentsScreen()),
                ),
              ),
              _buildActionItem(
                HugeIcons.strokeRoundedFile01,
                'Invoices',
                AppColors.primary,
                AppColors.accent,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BillingScreen()),
                ),
              ),
              _buildActionItem(
                HugeIcons.strokeRoundedHeadset,
                'Support',
                AppColors.primary,
                AppColors.accent,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SupportScreen()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    dynamic icon,
    String label,
    dynamic backgroundColor,
    dynamic iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border.all(color: backgroundColor),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: HugeIcon(icon: icon, size: 24, color: iconColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, List<BaseTransaction> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to common transaction history
                },
                child: const Row(
                  children: [
                    Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 4),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Center(
              child: Text(
                'No recent transactions found',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...transactions.map((t) => _buildTransactionItem(context, t)),
      ],
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    BaseTransaction transaction,
  ) {
    return InkWell(
      onTap: () {
        if (transaction.type == TransactionType.invoice) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => InvoiceDetailSheet(
              invoice: transaction.originalData as Invoice,
              onClose: () => Navigator.pop(context),
            ),
          );
        } else {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => PaymentDetailSheet(
              payment: transaction.originalData as Payment,
              onClose: () => Navigator.pop(context),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha:0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: transaction.statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: HugeIcon(icon: transaction.icon, size: 24, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM dd, yyyy').format(transaction.date),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary.withValues(alpha:0.7),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction.amount,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: transaction.statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: transaction.statusColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    transaction.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: transaction.statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
