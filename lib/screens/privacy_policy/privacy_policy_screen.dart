import 'package:flutter/material.dart';
import 'package:bdcomputing/components/shared/header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/core/styles.dart';
import 'package:bdcomputing/providers/settings_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacySection {
  final String id;
  final String title;
  final List<String> content;
  bool expanded;

  PrivacySection({
    required this.id,
    required this.title,
    required this.content,
    this.expanded = false,
  });
}

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late List<PrivacySection> sections;

  @override
  void initState() {
    super.initState();
    sections = [
      PrivacySection(
        id: '1',
        title: 'Information We Collect',
        content: [
          'Personal information (name, email, phone number, address)',
          'Payment information (credit card details, mobile money)',
          'Location data for fuel delivery services',
          'Device information and usage analytics',
          'Communication records and customer support interactions',
          'Order history and preferences',
        ],
      ),
      PrivacySection(
        id: '2',
        title: 'How We Use Your Information',
        content: [
          'Process and fulfill your fuel orders',
          'Provide customer support and respond to inquiries',
          'Send order confirmations and delivery updates',
          'Improve our services and user experience',
          'Send promotional offers and marketing communications (with consent)',
          'Comply with legal obligations and prevent fraud',
        ],
      ),
      PrivacySection(
        id: '3',
        title: 'Information Sharing',
        content: [
          'We do not sell your personal information to third parties',
          'Share with fuel suppliers and delivery partners to fulfill orders',
          'Share with payment processors for transaction processing',
          'Share with legal authorities when required by law',
          'Share with service providers who assist in our operations',
          'All third-party sharing is governed by strict confidentiality agreements',
        ],
      ),
      PrivacySection(
        id: '4',
        title: 'Data Security',
        content: [
          'We implement industry-standard security measures',
          'All data is encrypted during transmission and storage',
          'Regular security audits and vulnerability assessments',
          'Limited access to personal data on a need-to-know basis',
          'Secure payment processing with PCI DSS compliance',
          'Immediate notification in case of any security breaches',
        ],
      ),
      PrivacySection(
        id: '5',
        title: 'Your Rights',
        content: [
          'Access your personal information we hold',
          'Request correction of inaccurate data',
          'Request deletion of your personal information',
          'Opt-out of marketing communications',
          'Withdraw consent for data processing',
          'Request data portability in a structured format',
        ],
      ),
      PrivacySection(
        id: '6',
        title: 'Data Retention',
        content: [
          'We retain your data only as long as necessary',
          'Order history: 7 years for tax and legal compliance',
          'Account information: Until account deletion',
          'Marketing preferences: Until consent withdrawal',
          'Location data: 30 days after last use',
          'Payment information: As required by financial regulations',
        ],
      ),
      PrivacySection(
        id: '7',
        title: 'Cookies and Tracking',
        content: [
          'We use cookies to improve app functionality',
          'Analytics cookies to understand usage patterns',
          'Essential cookies for core app features',
          'You can control cookie preferences in app settings',
          'Third-party analytics with anonymized data',
          'No tracking for advertising without explicit consent',
        ],
      ),
      PrivacySection(
        id: '8',
        title: "Children's Privacy",
        content: [
          'Our services are not intended for children under 13',
          'We do not knowingly collect data from children under 13',
          'If we discover we have collected such data, we will delete it',
          "Parents can contact us to review or delete children's data",
          'Age verification may be required for certain services',
        ],
      ),
      PrivacySection(
        id: '9',
        title: 'International Data Transfers',
        content: [
          'Your data may be processed in different countries',
          'We ensure adequate protection for international transfers',
          'Compliance with local data protection laws',
          'Standard contractual clauses for EU data transfers',
          'Regular assessment of international data handling practices',
        ],
      ),
      PrivacySection(
        id: '10',
        title: 'Changes to This Policy',
        content: [
          'We may update this privacy policy periodically',
          'Significant changes will be notified via email or app notification',
          'Continued use of the app constitutes acceptance of changes',
          'Previous versions are available upon request',
          'Review this policy regularly for updates',
        ],
      ),
    ];
  }

  void toggleSection(String id) {
    setState(() {
      final index = sections.indexWhere((section) => section.id == id);
      if (index != -1) {
        sections[index].expanded = !sections[index].expanded;
      }
    });
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const Header(title: 'Privacy Policy'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Header Section
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'At Pedea, we are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, and safeguard your data when you use our fuel delivery services.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4B5563),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Privacy Sections
            ...sections.map((section) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${section.id}. ${section.title}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => toggleSection(section.id),
                      child: Container(
                        decoration: BoxDecoration(
                          color: section.expanded
                              ? const Color(0xFFDCFCE7)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              section.expanded
                                  ? 'Hide Details'
                                  : 'Show Details',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF166534),
                              ),
                            ),
                            Icon(
                              section.expanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: const Color(0xFF16A34A),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (section.expanded) ...[
                      const SizedBox(height: 16),
                      ...section.content.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '• ',
                                style: TextStyle(
                                  color: Color(0xFF374151),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    color: Color(0xFF374151),
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              );
            }),

            // Contact Section
            Consumer(
              builder: (context, ref, _) {
                final settings = ref.watch(settingsProvider);
                final email =
                    settings?.general.email ?? 'info@pedeapetroleum.com';
                final phone = settings?.general.phone ?? '+254701514044';
                final addressText = settings != null
                    ? '${settings.general.address.town}, ${settings.general.address.country}'
                    : 'Eldoret, Kenya';
                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contact Us',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'If you have any questions about this Privacy Policy or our data practices, please contact us:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4B5563),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _launchEmail(email),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.email_outlined,
                                size: 20,
                                color: Color(0xFF572fff),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _launchPhone(phone),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.phone_outlined,
                                size: 20,
                                color: Color(0xFF572fff),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                phone.replaceAllMapped(
                                  RegExp(r'^(\+?\d{3})(\d{3})(\d{3})(\d{3})$'),
                                  (m) => '${m[1]} ${m[2]} ${m[3]} ${m[4]}',
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 20,
                              color: Color(0xFF572fff),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              addressText,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Footer
            Container(
              margin: const EdgeInsets.only(bottom: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
              ),
              child: const Text(
                'By using Pedea\'s services, you acknowledge that you have read and understood this Privacy Policy and agree to the collection, use, and disclosure of your information as described herein.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4B5563),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
