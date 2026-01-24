import 'package:bdoneapp/screens/billing/invoices_screen.dart';
import 'package:bdoneapp/screens/billing/invoices_provider.dart';
import 'package:bdoneapp/screens/payments/payments_screen.dart';
import 'package:bdoneapp/screens/profile/profile_screen.dart';
import 'package:bdoneapp/screens/projects/lead_projects_screen.dart';
import 'package:bdoneapp/screens/projects/lead_projects_provider.dart';
import 'package:bdoneapp/screens/projects/projects_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bdoneapp/screens/auth/presentation/auth_guard.dart';
import 'package:bdoneapp/core/styles.dart';
import 'package:bdoneapp/screens/home_screen.dart';

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeTab(),
    LeadProjectsScreen(),
    ProjectsScreen(),
    BillingScreen(),
    PaymentsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: IndexedStack(index: _currentIndex, children: _screens),
        ),
        bottomNavigationBar: Consumer(
          builder: (context, ref, _) {
            final unpaidCount = ref.watch(unpaidInvoicesCountProvider);
            final pendingRequestsCount = ref.watch(pendingQuoteRequestsCountProvider);
            return BottomNavigationBar(
              backgroundColor: AppColors.surface,
              currentIndex: _currentIndex,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              items: [
                const BottomNavigationBarItem(
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedHome01, size: 30),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedFileValidation,
                        size: 30,
                      ),
                      if (pendingRequestsCount > 0)
                        Positioned(
                          top: -6,
                          right: -12,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                '$pendingRequestsCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: 'Requests',
                ),
                 const BottomNavigationBarItem(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedFolderFileStorage,
                    size: 30,
                  ),
                  label: 'Projects',
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedInvoice01,
                        size: 30,
                      ),
                      if (unpaidCount > 0)
                        Positioned(
                          top: -6,
                          right: -12,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                '$unpaidCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: 'Invoices',
                ),
                const BottomNavigationBarItem(
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedWallet03, size: 30),
                  label: 'Payments',
                ),

                const BottomNavigationBarItem(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedUser,
                    size: 30,
                  ),
                  label: 'Profile',
                ),
              ],
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            );
          },
        ),
      ),
    );
  }
}
