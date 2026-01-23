import 'package:flutter/material.dart';
import 'package:bdcomputing/components/shared/header.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/core/styles.dart';
import 'package:bdcomputing/providers/settings_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class GetHelpScreen extends StatefulWidget {
  const GetHelpScreen({super.key});

  @override
  State<GetHelpScreen> createState() => _GetHelpScreenState();
}

class _GetHelpScreenState extends State<GetHelpScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _expandedIndex;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _faqCategories = [
    {
      'title': 'Getting Started',
      'icon': Icons.rocket_launch_outlined,
      'color': const Color(0xFF10B981),
      'faqs': [
        {
          'question': 'How do I create an account?',
          'answer':
              'To create an account, tap on the "Sign Up" button on the login screen. Fill in your details including name, email, phone number, and password. Verify your email and phone number to complete registration.',
        },
        {
          'question': 'How do I place my first fuel order?',
          'answer':
              'Navigate to the home screen, select your preferred fuel type (Petrol, Diesel, etc.), choose the quantity, select bulk or retail order type, pick a vendor, and proceed to checkout. You can track your order in real-time.',
        },
        {
          'question': 'What payment methods are accepted?',
          'answer':
              'We accept M-Pesa, credit/debit cards, and bank transfers. For bulk orders, you can also set up a corporate account with credit terms.',
        },
      ],
    },
    {
      'title': 'Orders & Delivery',
      'icon': Icons.local_shipping_outlined,
      'color': const Color(0xFF3B82F6),
      'faqs': [
        {
          'question': 'How long does delivery take?',
          'answer':
              'Express delivery typically takes 2-4 hours, while standard delivery takes 24-48 hours. Scheduled deliveries can be arranged according to your preferred date and time.',
        },
        {
          'question': 'Can I track my order?',
          'answer':
              'Yes! Once your order is confirmed, you can track it in real-time from the "My Orders" section. You\'ll receive notifications at each stage of delivery.',
        },
        {
          'question': 'What is the minimum order quantity?',
          'answer':
              'For retail orders, the minimum is 20 liters. For bulk orders, the minimum quantity is 1,000 liters. Contact our sales team for custom requirements.',
        },
        {
          'question': 'Can I cancel or modify my order?',
          'answer':
              'Orders can be cancelled or modified within 30 minutes of placement. After this time, please contact customer support for assistance.',
        },
      ],
    },
    {
      'title': 'Account & Security',
      'icon': Icons.security_outlined,
      'color': const Color(0xFF8B5CF6),
      'faqs': [
        {
          'question': 'How do I reset my password?',
          'answer':
              'On the login screen, tap "Forgot Password". Enter your email address and follow the instructions sent to your email to reset your password.',
        },
        {
          'question': 'Is my payment information secure?',
          'answer':
              'Yes, we use industry-standard encryption and comply with PCI DSS standards. Your payment information is never stored on our servers.',
        },
        {
          'question': 'How do I update my profile information?',
          'answer':
              'Go to Settings > Profile, where you can update your name, email, phone number, and delivery addresses. Changes are saved automatically.',
        },
      ],
    },
    {
      'title': 'Pricing & Billing',
      'icon': Icons.payments_outlined,
      'color': const Color(0xFFF59E0B),
      'faqs': [
        {
          'question': 'How are fuel prices determined?',
          'answer':
              'Fuel prices are set by individual vendors based on current market rates, delivery location, and order volume. Prices are displayed before you confirm your order.',
        },
        {
          'question': 'Do you offer bulk discounts?',
          'answer':
              'Yes, bulk orders (1,000+ liters) qualify for volume discounts. The discount percentage varies by vendor and is automatically applied at checkout.',
        },
        {
          'question': 'Are there any hidden charges?',
          'answer':
              'No hidden charges. All costs including VAT, delivery fees, and any applicable surcharges are clearly displayed before order confirmation.',
        },
      ],
    },
    {
      'title': 'Technical Support',
      'icon': Icons.build_outlined,
      'color': const Color(0xFFEC4899),
      'faqs': [
        {
          'question': 'The app is not working properly',
          'answer':
              'Try clearing the app cache or reinstalling the app. If the issue persists, contact our technical support team with details about the problem.',
        },
        {
          'question': 'I\'m not receiving notifications',
          'answer':
              'Check your device notification settings and ensure notifications are enabled for Pedea. Also verify your email and phone number are correct in your profile.',
        },
        {
          'question': 'How do I report a bug?',
          'answer':
              'You can report bugs through Settings > Report Issue, or email our technical team at info@bdcomputing.co.ke with a description of the issue and screenshots if possible.',
        },
      ],
    },
  ];

  List<Map<String, dynamic>> _getFilteredFAQs() {
    if (_searchQuery.isEmpty) {
      return _faqCategories;
    }

    return _faqCategories
        .map((category) {
          final filteredFaqs = (category['faqs'] as List).where((faq) {
            final question = faq['question'].toString().toLowerCase();
            final answer = faq['answer'].toString().toLowerCase();
            final query = _searchQuery.toLowerCase();
            return question.contains(query) || answer.contains(query);
          }).toList();

          return {...category, 'faqs': filteredFaqs};
        })
        .where((category) {
          return (category['faqs'] as List).isNotEmpty;
        })
        .toList();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const Header(title: 'Help Center'),
      body: Column(
        children: [
          _buildHeroSection(),
          _buildSearchBar(),
          _buildQuickActions(),
          Expanded(child: _buildFAQSection()),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 0, 105, 70),
            Color.fromARGB(255, 0, 22, 15),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.help_outline,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'How can we help you?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Find answers to common questions below',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search for help...',
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF6B7280)),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, ref, _) {
              final settings = ref.watch(settingsProvider);
              final email =
                  settings?.general.email ?? 'info@bdcomputing.co.ke';
              final phone = settings?.general.phone ?? '+254701514044';
              final prettyPhone = phone.replaceAllMapped(
                RegExp(r'^(\+?\d{3})(\d{3})(\d{3})(\d{3})$'),
                (m) => '${m[1]} ${m[2]} ${m[3]} ${m[4]}',
              );
              return Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.phone_outlined,
                      title: 'Call Support',
                      subtitle: prettyPhone,
                      color: const Color(0xFF3B82F6),
                      onTap: () =>
                          _launchUrl('tel:${phone.replaceAll(' ', '')}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.email_outlined,
                      title: 'Email Us',
                      subtitle: email,
                      color: const Color(0xFF8B5CF6),
                      onTap: () => _launchUrl('mailto:$email'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    final filteredFAQs = _getFilteredFAQs();

    if (filteredFAQs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text(
                'No results found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching with different keywords',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredFAQs.length,
      itemBuilder: (context, categoryIndex) {
        final category = filteredFAQs[categoryIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (categoryIndex > 0) const SizedBox(height: 24),
            _buildCategoryHeader(category),
            const SizedBox(height: 12),
            ...List.generate((category['faqs'] as List).length, (faqIndex) {
              final globalIndex = categoryIndex * 1000 + faqIndex;
              return _buildFAQItem(category['faqs'][faqIndex], globalIndex);
            }),
          ],
        );
      },
    );
  }

  Widget _buildCategoryHeader(Map<String, dynamic> category) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (category['color'] as Color).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            category['icon'] as IconData,
            color: category['color'] as Color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          category['title'],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> faq, int index) {
    final isExpanded = _expandedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedIndex = isExpanded ? null : index;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      faq['question'],
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isExpanded
                            ? const Color(0xFF10B981)
                            : const Color(0xFF111827),
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.remove_circle_outline
                        : Icons.add_circle_outline,
                    color: isExpanded
                        ? const Color(0xFF10B981)
                        : const Color(0xFF6B7280),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Text(
                    faq['answer'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
