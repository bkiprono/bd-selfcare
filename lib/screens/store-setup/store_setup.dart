import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/screens/auth/domain/auth_state.dart' show Authenticated;
import 'package:bdcomputing/screens/auth/domain/user_model.dart';
import 'package:bdcomputing/screens/auth/providers.dart';
import 'package:bdcomputing/components/shared/header.dart';
import 'package:bdcomputing/core/styles.dart';
import 'package:bdcomputing/models/common/country.dart';
import 'package:bdcomputing/models/common/vendor.dart';
import 'package:bdcomputing/core/utils/api_exception.dart';
import 'package:bdcomputing/core/endpoints.dart';
import 'package:bdcomputing/providers/providers.dart';
import 'package:bdcomputing/components/shared/custom_text_field.dart';
import 'package:bdcomputing/components/shared/country_picker_field.dart';
import 'package:bdcomputing/components/shared/section_card.dart';
import 'package:bdcomputing/components/shared/custom_button.dart';

class StoreSetupScreen extends ConsumerStatefulWidget {
  const StoreSetupScreen({super.key});

  @override
  ConsumerState<StoreSetupScreen> createState() => _StoreSetupScreenState();
}

class _StoreSetupScreenState extends ConsumerState<StoreSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasChanges = false;

  // Business Information
  late TextEditingController _businessNameCtrl;
  late TextEditingController _businessEmailCtrl;
  late TextEditingController _businessPhoneCtrl;
  late TextEditingController _taxIdCtrl;

  // Business Address
  late TextEditingController _streetCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _stateCtrl;
  late TextEditingController _zipCodeCtrl;
  Country? _selectedCountry;

  // Additional Information
  late TextEditingController _idNumberCtrl;
  late TextEditingController _registrationNumberCtrl;

  // Contact Person
  late TextEditingController _contactNameCtrl;
  late TextEditingController _contactEmailCtrl;
  late TextEditingController _contactPhoneCtrl;

  Vendor? _vendor;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _businessNameCtrl = TextEditingController();
    _businessEmailCtrl = TextEditingController();
    _businessPhoneCtrl = TextEditingController();
    _taxIdCtrl = TextEditingController();
    _streetCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _stateCtrl = TextEditingController();
    _zipCodeCtrl = TextEditingController();
    _idNumberCtrl = TextEditingController();
    _registrationNumberCtrl = TextEditingController();
    _contactNameCtrl = TextEditingController();
    _contactEmailCtrl = TextEditingController();
    _contactPhoneCtrl = TextEditingController();

    // Add listeners to detect changes
    _businessNameCtrl.addListener(_onFieldChanged);
    _businessEmailCtrl.addListener(_onFieldChanged);
    _businessPhoneCtrl.addListener(_onFieldChanged);
    _taxIdCtrl.addListener(_onFieldChanged);
    _streetCtrl.addListener(_onFieldChanged);
    _cityCtrl.addListener(_onFieldChanged);
    _stateCtrl.addListener(_onFieldChanged);
    _zipCodeCtrl.addListener(_onFieldChanged);
    _idNumberCtrl.addListener(_onFieldChanged);
    _registrationNumberCtrl.addListener(_onFieldChanged);
    _contactNameCtrl.addListener(_onFieldChanged);
    _contactEmailCtrl.addListener(_onFieldChanged);
    _contactPhoneCtrl.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  void _loadVendorData(User user) {
    if (_vendor != null) return; // Already loaded
    
    setState(() {
      _vendor = user.vendor;
      if (_vendor != null) {
        _businessNameCtrl.text = _vendor!.name;
        _businessEmailCtrl.text = _vendor!.email;
        _businessPhoneCtrl.text = _vendor!.phone;
        _taxIdCtrl.text = _vendor!.taxId;
        _streetCtrl.text = _vendor!.street;
        _cityCtrl.text = _vendor!.city;
        _stateCtrl.text = _vendor!.state;
        _zipCodeCtrl.text = _vendor!.zipCode;
        _idNumberCtrl.text = _vendor!.idNumber ?? '';
        _registrationNumberCtrl.text = _vendor!.registrationNumber ?? '';
        _contactNameCtrl.text = _vendor!.contactPersonName;
        _contactEmailCtrl.text = _vendor!.contactPersonEmail;
        _contactPhoneCtrl.text = _vendor!.contactPersonPhone;
        _selectedCountry = _vendor!.country;
        _hasChanges = false;
      }
    });
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _businessEmailCtrl.dispose();
    _businessPhoneCtrl.dispose();
    _taxIdCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCodeCtrl.dispose();
    _idNumberCtrl.dispose();
    _registrationNumberCtrl.dispose();
    _contactNameCtrl.dispose();
    _contactEmailCtrl.dispose();
    _contactPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (_vendor == null || _selectedCountry == null) return;

    setState(() => _isLoading = true);
    try {
      final apiClient = ref.read(apiClientProvider);

      // Prepare update data
      final updateData = {
        'name': _businessNameCtrl.text.trim(),
        'email': _businessEmailCtrl.text.trim(),
        'phone': _businessPhoneCtrl.text.trim(),
        'taxId': _taxIdCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'countryId': _selectedCountry!.id,
        'street': _streetCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'zipCode': _zipCodeCtrl.text.trim(),
        'idNumber': _idNumberCtrl.text.trim().isEmpty ? null : _idNumberCtrl.text.trim(),
        'registrationNumber': _registrationNumberCtrl.text.trim().isEmpty
            ? null
            : _registrationNumberCtrl.text.trim(),
        'contactPersonName': _contactNameCtrl.text.trim(),
        'contactPersonPhone': _contactPhoneCtrl.text.trim(),
        'contactPersonEmail': _contactEmailCtrl.text.trim(),
      };

      // Update vendor via API
      await apiClient.put(
        '${ApiEndpoints.vendors}/me',
        data: updateData,
      );

      // Refresh user profile
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.refreshProfile();

      if (mounted) {
        setState(() => _hasChanges = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Store information updated successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(e.message)),
              ],
            ),
            backgroundColor: Colors.red[800],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Failed to update store information: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red[800],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final user = state is Authenticated ? state.user : null;

    if (user != null && _vendor == null) {
      _loadVendorData(user);
    }

    return Scaffold(
      appBar: Header(
        title: 'Store Setup',
        showBackButton: true,
        centerTitle: false,
        showProfileIcon: true,
        showCurrencyIcon: true,
        actions: _hasChanges
            ? [
                TextButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ]
            : [],
      ),
      backgroundColor: Colors.grey[50],
      body: user == null || _vendor == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionCard(
                      title: 'Business Information',
                      children: [
                        CustomTextField(
                          label: 'Business Name',
                          controller: _businessNameCtrl,
                          hintText: 'e.g., BD Engineering Co',
                          prefixIcon: Icons.business_outlined,
                          isRequired: true,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Business name is required'
                              : null,
                          readOnly: _isLoading,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Business Email',
                          controller: _businessEmailCtrl,
                          hintText: 'e.g., business@example.com',
                          prefixIcon: Icons.email_outlined,
                          isRequired: true,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Business email is required'
                              : null,
                          readOnly: _isLoading,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Business Phone',
                          controller: _businessPhoneCtrl,
                          hintText: 'e.g., 0719155083',
                          prefixIcon: Icons.phone_outlined,
                          isRequired: true,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Business phone is required'
                              : null,
                          readOnly: _isLoading,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Tax ID',
                          controller: _taxIdCtrl,
                          hintText: 'e.g., P880806C9H',
                          prefixIcon: Icons.description_outlined,
                          isRequired: true,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Tax ID is required'
                              : null,
                          readOnly: _isLoading,
                        ),
                      ],
                    ),
                    SectionCard(
                      title: 'Business Address',
                      children: [
                        CountryPickerField(
                          label: 'Country',
                          isRequired: true,
                          controller: TextEditingController(
                            text: _selectedCountry?.name ?? '',
                          ),
                          onSelected: (country) {
                            setState(() {
                              _selectedCountry = country;
                              _hasChanges = true;
                            });
                          },
                          validator: (v) => _selectedCountry == null
                              ? 'Country is required'
                              : null, selectedCountry: null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Street Address',
                          controller: _streetCtrl,
                          hintText: 'e.g., Ronald Ngala Street',
                          prefixIcon: Icons.location_on_outlined,
                          isRequired: true,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Street address is required'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'City',
                                controller: _cityCtrl,
                                hintText: 'e.g., Eldoret',
                                prefixIcon: Icons.location_city_outlined,
                                isRequired: true,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'City is required'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomTextField(
                                label: 'State/Region',
                                controller: _stateCtrl,
                                hintText: 'e.g., Uasin Gishu',
                                prefixIcon: Icons.map_outlined,
                                isRequired: true,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'State is required'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Zip/Postal Code',
                          controller: _zipCodeCtrl,
                          hintText: 'e.g., 30100',
                          prefixIcon: Icons.markunread_mailbox_outlined,
                          isRequired: true,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Zip code is required'
                              : null,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    SectionCard(
                      title: 'Additional Information',
                      children: [
                        CustomTextField(
                          label: 'ID Number (Optional)',
                          controller: _idNumberCtrl,
                          hintText: 'Enter ID number',
                          prefixIcon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Registration Number (Optional)',
                          controller: _registrationNumberCtrl,
                          hintText: 'Enter registration number',
                          prefixIcon: Icons.app_registration_outlined,
                        ),
                      ],
                    ),
                    SectionCard(
                      title: 'Contact Person',
                      children: [
                        CustomTextField(
                          label: 'Full Name',
                          controller: _contactNameCtrl,
                          hintText: 'e.g., Brian Koech',
                          prefixIcon: Icons.person_outline,
                          isRequired: true,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Contact name is required'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Email Address',
                          controller: _contactEmailCtrl,
                          hintText: 'e.g., brian@bdcomputing.co.ke',
                          prefixIcon: Icons.email_outlined,
                          isRequired: true,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Contact email is required'
                              : null,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Phone Number',
                          controller: _contactPhoneCtrl,
                          hintText: 'e.g., 0719155083',
                          prefixIcon: Icons.phone_outlined,
                          isRequired: true,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Contact phone is required'
                              : null,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                    SectionCard(
                      title: 'Account Information',
                      children: [
                        _buildReadOnlyField(
                          label: 'Account Serial',
                          value: _vendor!.serial,
                          icon: Icons.qr_code_outlined,
                        ),
                        const SizedBox(height: 12),
                        if (_vendor!.uniqueId != null)
                          _buildReadOnlyField(
                            label: 'Unique ID',
                            value: _vendor!.uniqueId.toString(),
                            icon: Icons.numbers_outlined,
                          ),
                        const SizedBox(height: 12),
                        _buildReadOnlyField(
                          label: 'Verification Status',
                          value: _vendor!.verified ? 'Verified' : 'Not Verified',
                          icon: _vendor!.verified
                              ? Icons.verified_outlined
                              : Icons.pending_outlined,
                          valueColor:
                              _vendor!.verified ? Colors.green : Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Save Changes',
                      onPressed: _saveChanges,
                      isLoading: _isLoading,
                      isDisabled: !_hasChanges,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }



  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: valueColor ?? Colors.black87,
                    fontWeight: FontWeight.w600,
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
