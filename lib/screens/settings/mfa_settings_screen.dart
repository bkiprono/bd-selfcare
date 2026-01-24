import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/core/styles.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:bdcomputing/screens/auth/auth_provider.dart';
import 'package:bdcomputing/screens/auth/domain/mfa_models.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MfaSettingsScreen extends ConsumerStatefulWidget {
  const MfaSettingsScreen({super.key});

  @override
  ConsumerState<MfaSettingsScreen> createState() => _MfaSettingsScreenState();
}

class _MfaSettingsScreenState extends ConsumerState<MfaSettingsScreen> {
  bool _isLoading = false;

  Future<void> _toggleMethod(MfaMethod method, bool enabled) async {
    if (method == MfaMethod.totp) {
      if (enabled) {
        _showTotpSetup();
      } else {
        _showDisableTotpConfirm();
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).toggleMfaMethod(method, enabled);
      Fluttertoast.showToast(msg: 'MFA settings updated');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Update failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showTotpSetup() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final setupData = await ref.read(authProvider.notifier).startTotpSetup();
      final String qrUrl = setupData['qrCodeUrl'] ?? '';
      final String setupToken = setupData['setupToken'] ?? '';
      final String secret = setupData['secret'] ?? '';

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _TotpSetupModal(
          qrUrl: qrUrl,
          setupToken: setupToken,
          secret: secret,
          onComplete: () {
            ref.read(authProvider.notifier).refreshProfile();
            Navigator.pop(context);
          },
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to start setup: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDisableTotpConfirm() {
    final passwordCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable Authenticator'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your account password to disable the Authenticator App MFA.'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final password = passwordCtrl.text;
              if (password.isEmpty) return;
              
              Navigator.pop(context);
              if (mounted) setState(() => _isLoading = true);
              try {
                await ref.read(authProvider.notifier).disableTotp(password);
                Fluttertoast.showToast(msg: 'Authenticator disabled');
              } catch (e) {
                Fluttertoast.showToast(msg: 'Failed to disable: $e');
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Disable'),
          ),
        ],
      ),
    );
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

class _TotpSetupModal extends ConsumerStatefulWidget {
  final String qrUrl;
  final String setupToken;
  final String secret;
  final VoidCallback onComplete;

  const _TotpSetupModal({
    required this.qrUrl,
    required this.setupToken,
    required this.secret,
    required this.onComplete,
  });

  @override
  ConsumerState<_TotpSetupModal> createState() => _TotpSetupModalState();
}

class _TotpSetupModalState extends ConsumerState<_TotpSetupModal> {
  final _codeCtrl = TextEditingController();
  bool _isVerifying = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Text('Setup Authenticator App', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              '1. Scan the QR code with your authenticator app (Google Authenticator, Authy, etc.)\n'
              '2. Enter the 6-digit code generated by the app.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 32),
            if (widget.qrUrl.isNotEmpty) 
              Center(
                child: QrImageView(
                  data: widget.qrUrl,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
            const SizedBox(height: 16),
            const Text('Or enter this code manually:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(12)),
              child: SelectableText(widget.secret, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _codeCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: const InputDecoration(
                hintText: '000000',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _handleComplete,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isVerifying ? const CircularProgressIndicator(color: Colors.white) : const Text('Complete Setup'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _handleComplete() async {
    final code = _codeCtrl.text;
    if (code.length < 6) return;

    setState(() => _isVerifying = true);
    try {
      await ref.read(authProvider.notifier).completeTotpSetup(widget.setupToken, code);
      Fluttertoast.showToast(msg: 'Setup successful!');
      widget.onComplete();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Verification failed: $e');
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }
}
