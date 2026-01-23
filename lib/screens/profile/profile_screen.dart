import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/screens/auth/domain/auth_state.dart'
    show Authenticated;
import 'package:bdcomputing/screens/auth/presentation/auth_guard.dart';
import 'package:bdcomputing/screens/auth/providers.dart';
import 'package:bdcomputing/components/shared/header.dart';
import 'package:bdcomputing/components/widgets/user_widget.dart';
import 'package:bdcomputing/core/mixins/token_validation_mixin.dart';
import 'package:bdcomputing/core/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TokenValidationMixin {
  Future<void> _openExternalLink(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.inAppWebView)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final user = state is Authenticated ? state.user : null;

    return AuthGuard(
      child: Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Header(title: 'Profile', showProfileIcon: false, actions: []),
        ),
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: user == null
              ? const Center(
                  child: Text('Session expired. Please log in again.'),
                )
              : Column(
                  children: [
                    const SizedBox(height: 10),

                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: UserWidget(
                                user: user,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Account Settings Card
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildMenuItem(
                                    icon: Icons.settings_outlined,
                                    title: 'Settings',
                                    subtitle: 'Account and app settings',
                                    onTap: () => validateTokenBeforeAction(() {
                                      // TODO: Navigate to settings screen
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Settings coming soon'),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Support & Legal Card
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                children: [
                                  _buildMenuItem(
                                    icon: Icons.headset_mic_outlined,
                                    title: 'Contact Support',
                                    subtitle: 'Get help from our team',
                                    onTap: () => Navigator.of(
                                      context,
                                    ).pushNamed('/contact_us'),
                                  ),
                                  _buildDivider(),
                                  _buildMenuItem(
                                    icon: Icons.help_outline,
                                    title: 'Help Center',
                                    subtitle: 'FAQs and guides',
                                    onTap: () => _openExternalLink(
                                      'https://bdcomputing.co.ke/contact-us',
                                    ),
                                  ),
                                  _buildDivider(),
                                  _buildMenuItem(
                                    icon: Icons.shield_outlined,
                                    title: 'Privacy Policy',
                                    subtitle: null,
                                    onTap: () => _openExternalLink(
                                      'https://bdcomputing.co.ke/terms/privacy-policy',
                                    ),
                                  ),
                                  _buildDivider(),
                                  _buildMenuItem(
                                    icon: Icons.description_outlined,
                                    title: 'Terms & Conditions',
                                    subtitle: null,
                                    onTap: () => _openExternalLink(
                                      'https://bdcomputing.co.ke/terms/terms-and-conditions',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Logout Card
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: _buildMenuItem(
                                icon: Icons.logout_outlined,
                                title: 'Log out',
                                subtitle: null,
                                textColor: Colors.red[700],
                                onTap: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Log out?'),
                                      content: const Text(
                                        'Are you sure you want to log out?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(true),
                                          child: const Text('Log out'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    await ref
                                        .read(authProvider.notifier)
                                        .logout();
                                    if (context.mounted) {
                                      Navigator.of(
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        '/',
                                        (route) => false,
                                      );
                                    }
                                  }
                                },
                              ),
                            ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: textColor != null
                    ? textColor.withOpacity(0.1)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: textColor ?? Colors.black87, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? Colors.black,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: textColor ?? const Color(0xFF9E9E9E),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: 1,
      color: const Color(0xFFF0F0F0),
    );
  }
}
