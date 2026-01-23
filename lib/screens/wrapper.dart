import 'package:bdcomputing/screens/billing/invoices_screen.dart';
import 'package:bdcomputing/screens/payments/payments_screen.dart';
import 'package:bdcomputing/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bdcomputing/screens/auth/presentation/auth_guard.dart';
import 'package:bdcomputing/core/styles.dart';
import 'package:bdcomputing/screens/home_screen.dart';

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeTab(),
    HomeTab(),
    BillingScreen(),
    PaymentsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: Consumer(
          builder: (context, ref, _) {
            const itemCount = 10;
            return BottomNavigationBar(
              backgroundColor: Colors.white,
              currentIndex: _currentIndex,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.grey,
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
                const BottomNavigationBarItem(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedWork,
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
                      if (itemCount > 0)
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
                            child: const Center(
                              child: Text(
                                '$itemCount',
                                style: TextStyle(
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
