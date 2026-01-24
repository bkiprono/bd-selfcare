import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/core/styles.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bdcomputing/screens/auth/auth_provider.dart';
import 'package:bdcomputing/screens/auth/domain/mfa_models.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MfaSettingsScreen extends ConsumerStatefulWidget {
  const MfaSettingsScreen({super.key});

  @override
  ConsumerState<MfaSettingsScreen> createState() => _MfaSettingsScreenState();
}

class _MfaSettingsScreenState extends ConsumerState<MfaSettingsScreen> {
  bool _isLoading = false;

  Future<void> _toggleMethod(MfaMethod method, bool enabled) async {
    setState(() => _isLoading = true);
    try {
      if (method == MfaMethod.totp && enabled) {
        // Handle TOTP setup flow separately if needed
        // For now mirroring CRM: open setup dialog/screen
        _showTotpSetup();
        return;
      }

      await ref.read(authProvider.notifier).toggleMfaMethod(method, enabled);
      Fluttertoast.showToast(msg: 'MFA settings updated');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Update failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showTotpSetup() {
    // Placeholder for TOTP setup flow
    Fluttertoast.showToast(msg: 'TOTP Setup flow starting...');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState is Authenticated ? authState.user : null;

    if (user == null)
      return const Scaffold(body: Center(child: Text('Not logged in')));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'MFA & Security',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Header Status Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: user.mfaEnabled
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: HugeIcon(
                          icon: user.mfaEnabled
                              ? HugeIcons.strokeRoundedShield01
                              : HugeIcons.strokeRoundedShield02,
                          color: user.mfaEnabled ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.mfaEnabled
                                  ? 'Protection Active'
                                  : 'MFA Disabled',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: user.mfaEnabled
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            const Text(
                              'Add an extra layer of security to your account.',
                              style: TextStyle(
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
                const SizedBox(height: 24),

                // Methods List
                _buildMethodCard(
                  title: 'Email OTP',
                  subtitle: 'Verification codes sent to registered email.',
                  icon: HugeIcons.strokeRoundedMail01,
                  iconBg: Colors.blue.withOpacity(0.1),
                  iconColor: Colors.blue,
                  isSelected: user.mfaMethods.contains(MfaMethod.email),
                  onChanged: (val) => _toggleMethod(MfaMethod.email, val),
                ),
                const SizedBox(height: 12),

                _buildMethodCard(
                  title: 'WhatsApp',
                  subtitle: user.phone != null
                      ? 'Official WhatsApp notifications.'
                      : 'Setup phone number first.',
                  icon: HugeIcons.strokeRoundedWhatsapp,
                  iconBg: Colors.green.withOpacity(0.1),
                  iconColor: Colors.green,
                  isSelected: user.mfaMethods.contains(MfaMethod.whatsapp),
                  enabled: user.phone != null,
                  badge: user.phone != null && user.whatsappVerified
                      ? _buildBadge('Verified', Colors.green)
                      : user.phone != null
                      ? _buildBadge('Verification Pending', Colors.orange)
                      : null,
                  onChanged: (val) => _toggleMethod(MfaMethod.whatsapp, val),
                ),
                const SizedBox(height: 12),

                _buildMethodCard(
                  title: 'Authenticator App',
                  subtitle: 'Secure app-based codes (TOTP).',
                  icon: HugeIcons.strokeRoundedShield01,
                  iconBg: Colors.purple.withOpacity(0.1),
                  iconColor: Colors.purple,
                  isSelected: user.mfaMethods.contains(MfaMethod.totp),
                  badge: !user.mfaMethods.contains(MfaMethod.totp)
                      ? _buildBadge(
                          'Setup Required',
                          AppColors.primary,
                          isUnderlined: true,
                        )
                      : null,
                  onChanged: (val) => _toggleMethod(MfaMethod.totp, val),
                ),
              ],
            ),
    );
  }

  Widget _buildMethodCard({
    required String title,
    required String subtitle,
    required dynamic icon,
    required Color iconBg,
    required Color iconColor,
    required bool isSelected,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
    Widget? badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withOpacity(0.5)
              : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: HugeIcon(icon: icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (badge != null) ...[const SizedBox(width: 8), badge],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: isSelected,
              onChanged: enabled ? onChanged : null,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color, {bool isUnderlined = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          decoration: isUnderlined ? TextDecoration.underline : null,
        ),
      ),
    );
  }
}
