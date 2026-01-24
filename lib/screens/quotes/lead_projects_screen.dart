import 'package:bdoneapp/components/shared/header.dart';
import 'package:bdoneapp/components/logger_config.dart';
import 'package:bdoneapp/core/styles.dart';
import 'package:bdoneapp/models/common/lead_project.dart';
import 'package:bdoneapp/models/common/product.dart';
import 'package:bdoneapp/models/common/service.dart';
import 'package:bdoneapp/models/dtos/create_lead_project_dto.dart';
import 'package:bdoneapp/models/enums/lead_source.dart';
import 'package:bdoneapp/models/enums/project_type.dart';
import 'package:bdoneapp/providers/providers.dart';
import 'package:bdoneapp/providers/auth_providers.dart';
import 'package:bdoneapp/providers/lead_projects_provider.dart';
import 'package:bdoneapp/screens/quotes/lead_project_detail_screen.dart';
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
      appBar: const Header(
        title: 'Quote Requests',
        showProfileIcon: true,
        showCurrencyIcon: false,
        actions: [],
      ),
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Search
                    Expanded(
                      child: Container(
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
                                  ref
                                      .read(leadProjectsProvider.notifier)
                                      .setKeyword(val);
                                },
                              ),
                            ),
                          ],
                        ),
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
                            itemCount:
                                state.leadProjects.length +
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
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 18),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasQuote = leadProject.projectId != null;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration:  BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFE5E5E5),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    LeadProjectDetailScreen(leadProject: leadProject),
              ),
            );
          },
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
      ),
    );
  }
}

class CreateLeadProjectSheet extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;

  const CreateLeadProjectSheet({super.key, required this.onSuccess});

  @override
  ConsumerState<CreateLeadProjectSheet> createState() =>
      _CreateLeadProjectSheetState();
}

class _CreateLeadProjectSheetState
    extends ConsumerState<CreateLeadProjectSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _featuresController = TextEditingController();
  bool _isSubmitting = false;
  String _selectedProjectType = 'service'; // Default to service
  String _selectedSource = 'website'; // Default to website

  List<Product> _products = [];
  List<ServiceModel> _services = [];
  String? _selectedProductId;
  String? _selectedServiceId;
  String? _fetchError;
  bool _isLoadingItems = false;

  @override
  void initState() {
    super.initState();
    // Fetch items based on default project type
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() {
      _isLoadingItems = true;
      _fetchError = null;
      _selectedProductId = null;
      _selectedServiceId = null;
    });

    try {
      if (_selectedProjectType == 'product') {
        final products = await ref.read(productServiceProvider).fetchProducts();
        if (mounted) {
          setState(() {
            _products = products;
          });
        }
      } else if (_selectedProjectType == 'service') {
        final services = await ref.read(serviceServiceProvider).fetchServices();
        if (mounted) {
          setState(() {
            _services = services;
          });
        }
      }
    } catch (e) {
      logger.e('Error fetching items: $e');
      if (mounted) {
        setState(() {
          _fetchError = 'Failed to load items. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingItems = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _featuresController.dispose();
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

      // Parse features from comma-separated input
      List<String>? features;
      if (_featuresController.text.trim().isNotEmpty) {
        features = _featuresController.text
            .split(',')
            .map((f) => f.trim())
            .where((f) => f.isNotEmpty)
            .toList();
      }

      // Create DTO matching TypeScript CreateLeadProject interface
      final dto = CreateLeadProjectDto(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        source: LeadSourceEnum.fromString(_selectedSource),
        projectType: ProjectTypeEnum.fromString(_selectedProjectType),
        productId: _selectedProjectType == 'product'
            ? _selectedProductId
            : null,
        serviceId: _selectedProjectType == 'service'
            ? _selectedServiceId
            : null,
        duration: _durationController.text.trim().isNotEmpty
            ? _durationController.text.trim()
            : null,
        leadId: user?.leadId,
        clientId: user?.clientId,
        features: features,
      );

      final payload = dto.toJson();
      logger.d('Submitting lead project with payload: $payload'); // Debug log

      final result = await service.createLeadProject(payload);

      logger.i('Lead project created successfully: ${result.id}'); // Debug log

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Quote request submitted successfully! Our team will review it shortly.',
            ),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      logger.e('Error creating lead project: $e'); // Debug log

      // Extract more detailed error info
      String errorMessage = 'Failed to submit quote request';
      if (e.toString().contains('400')) {
        errorMessage = 'Invalid request data. Please check all fields.';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Authentication error. Please log in again.';
      } else if (e.toString().contains('403')) {
        errorMessage = 'You don\'t have permission to create quote requests.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request a Quote',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Request for a quote by filling in the details below',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            text: 'Project Title',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            children: [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            text: 'Project Description',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            children: [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            hintText: 'Enter a description',
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
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Source Selector (Required)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            text: 'Source',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            children: [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedSource,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'website',
                              child: Text('Website'),
                            ),
                            DropdownMenuItem(
                              value: 'referral',
                              child: Text('Referral'),
                            ),
                            DropdownMenuItem(
                              value: 'social_media',
                              child: Text('Social Media'),
                            ),
                            DropdownMenuItem(
                              value: 'email_campaign',
                              child: Text('Email Campaign'),
                            ),
                            DropdownMenuItem(
                              value: 'event',
                              child: Text('Event'),
                            ),
                            DropdownMenuItem(
                              value: 'advertisement',
                              child: Text('Advertisement'),
                            ),
                            DropdownMenuItem(
                              value: 'phone',
                              child: Text('Phone'),
                            ),
                            DropdownMenuItem(
                              value: 'walk_in',
                              child: Text('Walk In'),
                            ),
                            DropdownMenuItem(
                              value: 'other',
                              child: Text('Other'),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a source';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedSource = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Project Type Selector (Required)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            text: 'Project Type',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            children: [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedProjectType,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'service',
                              child: Text('Service'),
                            ),
                            DropdownMenuItem(
                              value: 'product',
                              child: Text('Product'),
                            ),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a project type';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedProjectType = value;
                              });
                              _fetchItems();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_selectedProjectType == 'product') ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  text: 'Choose Product',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: ' *',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                              if (_fetchError != null)
                                TextButton(
                                  onPressed: _fetchItems,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(50, 20),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Retry',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                          if (_fetchError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 4),
                              child: Text(
                                _fetchError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedProductId,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: _isLoadingItems
                                  ? 'Loading products...'
                                  : _fetchError != null
                                  ? 'Error loading products'
                                  : 'Select a product',
                              suffixIcon: _isLoadingItems
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Padding(
                                        padding: EdgeInsets.all(12),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            items: _products.map((p) {
                              return DropdownMenuItem(
                                value: p.id,
                                child: Text(p.name),
                              );
                            }).toList(),
                            validator: (value) {
                              if (_selectedProjectType == 'product' &&
                                  (value == null || value.isEmpty)) {
                                return 'Please select a product';
                              }
                              return null;
                            },
                            onChanged: _isLoadingItems
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedProductId = value;
                                    });
                                  },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (_selectedProjectType == 'service') ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  text: 'Choose Service',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: ' *',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                              if (_fetchError != null)
                                TextButton(
                                  onPressed: _fetchItems,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(50, 20),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Retry',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                          if (_fetchError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 4),
                              child: Text(
                                _fetchError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedServiceId,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: _isLoadingItems
                                  ? 'Loading services...'
                                  : _fetchError != null
                                  ? 'Error loading services'
                                  : 'Select a service',
                              suffixIcon: _isLoadingItems
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Padding(
                                        padding: EdgeInsets.all(12),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            items: _services.map((s) {
                              return DropdownMenuItem(
                                value: s.id,
                                child: Text(s.title),
                              );
                            }).toList(),
                            validator: (value) {
                              if (_selectedProjectType == 'service' &&
                                  (value == null || value.isEmpty)) {
                                return 'Please select a service';
                              }
                              return null;
                            },
                            onChanged: _isLoadingItems
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedServiceId = value;
                                    });
                                  },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Duration (Optional)
                    TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                        hintText: 'e.g., 2 weeks, 1 month',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Features Input
                    TextFormField(
                      controller: _featuresController,
                      decoration: const InputDecoration(
                        labelText: 'Features (Optional)',
                        hintText: 'Enter features separated by commas',
                        helperText:
                            'e.g., User authentication, Dashboard, Reports',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
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
