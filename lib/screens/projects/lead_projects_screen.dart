import 'package:bdcomputing/models/common/lead_project.dart';
import 'package:bdcomputing/providers/providers.dart';
import 'package:bdcomputing/screens/auth/providers.dart';
import 'package:bdcomputing/screens/projects/lead_projects_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class LeadProjectsScreen extends ConsumerStatefulWidget {
  const LeadProjectsScreen({super.key});

  @override
  ConsumerState<LeadProjectsScreen> createState() => _LeadProjectsScreenState();
}

class _LeadProjectsScreenState extends ConsumerState<LeadProjectsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateLeadProjectDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateLeadProjectSheet(
        onSuccess: () {
          ref.read(leadProjectsProvider.notifier).refresh();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leadProjectsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Quote Requests',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      IconButton(
                        onPressed: _showCreateLeadProjectDialog,
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedAdd01,
                          size: 24,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E5E5)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedSearch01,
                          size: 18,
                          color: Color(0xFF999999),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search quote requests...',
                              hintStyle: TextStyle(
                                color: Color(0xFF999999),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (val) {
                              ref.read(leadProjectsProvider.notifier).setKeyword(val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Lead Project List
            Expanded(
              child: state.isLoading && state.leadProjects.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null && state.leadProjects.isEmpty
                      ? Center(child: Text(state.error!))
                      : RefreshIndicator(
                          onRefresh: () =>
                              ref.read(leadProjectsProvider.notifier).refresh(),
                          child: state.leadProjects.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: state.leadProjects.length +
                                      (state.page <= state.totalPages ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == state.leadProjects.length) {
                                      ref
                                          .read(leadProjectsProvider.notifier)
                                          .fetchLeadProjects();
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }
                                    final leadProject = state.leadProjects[index];
                                    return LeadProjectCard(leadProject: leadProject);
                                  },
                                ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HugeIcon(
            icon: HugeIcons.strokeRoundedFileSearch,
            size: 64,
            color: Color(0xFFE5E7EB),
          ),
          const SizedBox(height: 16),
          Text(
            'No quote requests found',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _showCreateLeadProjectDialog,
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedAdd01,
              size: 18,
            ),
            label: const Text('Request a Quote'),
          ),
        ],
      ),
    );
  }
}

class LeadProjectCard extends ConsumerWidget {
  final LeadProject leadProject;

  const LeadProjectCard({super.key, required this.leadProject});

  Future<void> _fetchAndShowQuote(BuildContext context, WidgetRef ref) async {
    try {
      final quoteService = ref.read(quoteServiceProvider);
      // Find quote by leadProjectId
      final quotesResult = await quoteService.fetchQuotes(
        leadId: leadProject.leadId,
        clientId: leadProject.clientId,
        limit: 100,
      );
      
      final quote = quotesResult.data?.firstWhere(
        (q) => q.leadProjectId == leadProject.id,
        orElse: () => throw Exception('Quote not found'),
      );

      if (context.mounted && quote != null) {
        // TODO: Navigate to quote detail screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quote ${quote.serial} found!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading quote: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasQuote = leadProject.projectId != null;
    
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: InkWell(
        onTap: hasQuote ? () => _fetchAndShowQuote(context, ref) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                leadProject.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: hasQuote
                                    ? const Color(0xFFD1FAE5)
                                    : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                hasQuote ? 'QUOTED' : 'PENDING',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: hasQuote
                                      ? const Color(0xFF059669)
                                      : const Color(0xFFD97706),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          leadProject.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Created: ${DateFormat('MMM dd, yyyy').format(leadProject.createdAt)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasQuote)
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      size: 20,
                      color: Color(0xFF999999),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateLeadProjectSheet extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;

  const CreateLeadProjectSheet({super.key, required this.onSuccess});

  @override
  ConsumerState<CreateLeadProjectSheet> createState() => _CreateLeadProjectSheetState();
}

class _CreateLeadProjectSheetState extends ConsumerState<CreateLeadProjectSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = await ref.read(authProvider.notifier).getCurrentUser();
      final service = ref.read(leadProjectServiceProvider);

      final payload = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'duration': _durationController.text,
        'source': 'MOBILE_APP',
        'projectType': 'SERVICE', // Default, can be made selectable
        'clientId': user?.clientId,
        'leadId': user?.leadId,
      };

      await service.createLeadProject(payload);

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quote request submitted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Request a Quote',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    size: 20,
                    color: Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Project Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Estimated Duration',
                        hintText: 'e.g., 2 weeks, 1 month',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Submit Request',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
