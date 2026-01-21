import 'package:flutter/material.dart';
import 'package:bdcomputing/components/shared/header.dart';
import 'package:bdcomputing/core/styles.dart';
import 'package:bdcomputing/models/common/term_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/providers/providers.dart';

class TermsScreen extends ConsumerStatefulWidget {
  const TermsScreen({super.key});

  @override
  ConsumerState<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends ConsumerState<TermsScreen> {
  List<Term> _terms = [];
  String? _expandedTermId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    try {
      final termsService = ref.read(termsServiceProvider);
      final data = await termsService.fetchTermsAndConditions();
      setState(() {
        _terms = data;
        _loading = false;
      });
    } catch (error) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error fetching terms and conditions'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleExpand(String id) {
    setState(() {
      _expandedTermId = _expandedTermId == id ? null : id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const Header(title: 'Terms & Conditions'),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF4F46E5)),
                  SizedBox(height: 8),
                  Text(
                    'Loading terms...',
                    style: TextStyle(color: Color(0xFF16A34A), fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _terms.length,
              itemBuilder: (context, index) {
                final term = _terms[index];
                final isExpanded = _expandedTermId == term.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFF3F4F6),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          term.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _toggleExpand(term.id),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isExpanded
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
                                  isExpanded ? 'Hide Details' : 'Show Details',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF166534),
                                  ),
                                ),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: const Color(0xFF16A34A),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isExpanded) ...[
                          const SizedBox(height: 16),
                          ...term.content.map((item) {
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
                  ),
                );
              },
            ),
    );
  }
}
