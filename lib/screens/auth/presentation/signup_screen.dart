import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/models/common/country.dart';
import 'package:bdcomputing/models/enums/industry_enum.dart';
import 'package:bdcomputing/screens/auth/domain/client_registration_model.dart';
import 'package:bdcomputing/components/shared/custom_text_field.dart';
import 'package:bdcomputing/components/shared/custom_button.dart';
import 'package:bdcomputing/components/shared/country_picker_field.dart';
import 'package:bdcomputing/screens/auth/auth_provider.dart';
import 'package:bdcomputing/components/shared/auth_background.dart';
import 'package:bdcomputing/core/styles.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal Information
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // Account Type
  bool _isCorporate = false;

  // Tax & Business Information
  final _kraPINCtrl = TextEditingController();
  final _idNumberCtrl = TextEditingController();
  final _incorporationNumberCtrl = TextEditingController();
  Industry? _selectedIndustry;

  // Address
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipCodeCtrl = TextEditingController();
  Country? _selectedCountry;

  // Security
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _kraPINCtrl.dispose();
    _idNumberCtrl.dispose();
    _incorporationNumberCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCodeCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCountry == null) {
      _showError('Please select your country');
      return;
    }

    if (_selectedIndustry == null) {
      _showError('Please select your industry');
      return;
    }

    if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
      _showError('Passwords do not match');
      return;
    }

    setState(() => _submitting = true);
    try {
      final service = ref.read(authServiceProvider);

      final registration = ClientRegistration(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        kraPIN: _kraPINCtrl.text.trim().isEmpty
            ? null
            : _kraPINCtrl.text.trim(),
        idNumber: _idNumberCtrl.text.trim().isEmpty
            ? null
            : _idNumberCtrl.text.trim(),
        incorporationNumber: _incorporationNumberCtrl.text.trim().isEmpty
            ? null
            : _incorporationNumberCtrl.text.trim(),
        industry: _selectedIndustry!,
        countryId: _selectedCountry!.id,
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        street: _streetCtrl.text.trim(),
        zipCode: _zipCodeCtrl.text.trim(),
        isCorporate: _isCorporate,
        password: _passwordCtrl.text,
      );

      await service.signup(registration);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created successfully! Please log in.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedAlertCircle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final isLoading = _submitting || state is AuthLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: AuthBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Personal Information
                  _buildSectionTitle('Personal Information'),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Full Name',
                    controller: _nameCtrl,
                    hintText: 'e.g., John Doe',
                    prefixIcon: HugeIcons.strokeRoundedUser,
                    isRequired: true,
                    variant: 'filled',
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Full name is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Email Address',
                    controller: _emailCtrl,
                    hintText: 'e.g., john@example.com',
                    prefixIcon: HugeIcons.strokeRoundedMail01,
                    isRequired: true,
                    keyboardType: TextInputType.emailAddress,
                    variant: 'filled',
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(v)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Phone Number',
                    controller: _phoneCtrl,
                    hintText: 'e.g., 0719155083',
                    prefixIcon: HugeIcons.strokeRoundedSmartPhone01,
                    isRequired: true,
                    keyboardType: TextInputType.phone,
                    variant: 'filled',
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Phone number is required'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Account Type
                  _buildDropdownLabel('Account Type', true),
                  const SizedBox(height: 8),
                  _buildFilledDropdown<bool>(
                    value: _isCorporate,
                    items: const [
                      DropdownMenuItem(value: false, child: Text('Individual')),
                      DropdownMenuItem(value: true, child: Text('Corporate')),
                    ],
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _isCorporate = value ?? false;
                              _idNumberCtrl.clear();
                              _incorporationNumberCtrl.clear();
                            });
                          },
                  ),
                  const SizedBox(height: 32),

                  // Tax & Business Information
                  _buildSectionTitle('Tax & Business Information'),
                  const SizedBox(height: 16),

                  if (_isCorporate)
                    CustomTextField(
                      label: 'Incorporation Number',
                      controller: _incorporationNumberCtrl,
                      hintText: 'e.g., PVT-123456',
                      prefixIcon: HugeIcons.strokeRoundedBuilding01,
                      isRequired: false,
                      variant: 'filled',
                    )
                  else
                    CustomTextField(
                      label: 'ID Number',
                      controller: _idNumberCtrl,
                      hintText: 'e.g., 12345678',
                      prefixIcon: HugeIcons.strokeRoundedAiCloud,
                      isRequired: false,
                      keyboardType: TextInputType.number,
                      variant: 'filled',
                    ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'KRA PIN',
                    controller: _kraPINCtrl,
                    hintText: 'e.g., A123456789X',
                    prefixIcon: HugeIcons.strokeRoundedFileManagement,
                    isRequired: false,
                    variant: 'filled',
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownLabel('Industry', true),
                  const SizedBox(height: 8),
                  _buildFilledDropdown<Industry>(
                    value: _selectedIndustry,
                    hintText: 'Select Industry',
                    items: Industry.values.map((industry) {
                      return DropdownMenuItem(
                        value: industry,
                        child: Text(industry.displayName),
                      );
                    }).toList(),
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() => _selectedIndustry = value);
                          },
                  ),
                  const SizedBox(height: 32),

                  // Address Information
                  _buildSectionTitle('Address Information'),
                  const SizedBox(height: 16),
                  CountryPickerField(
                    selectedCountry: _selectedCountry,
                    onSelected: (c) => setState(() => _selectedCountry = c),
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Street Address',
                    controller: _streetCtrl,
                    hintText: 'e.g., Ronald Ngala Street',
                    prefixIcon: HugeIcons.strokeRoundedLocation01,
                    isRequired: true,
                    variant: 'filled',
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Street address is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'City/County',
                          controller: _cityCtrl,
                          hintText: 'e.g., Eldoret',
                          prefixIcon: HugeIcons.strokeRoundedLocation01,
                          isRequired: true,
                          variant: 'filled',
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'City is required'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: 'State/Town',
                          controller: _stateCtrl,
                          hintText: 'e.g., Uasin Gishu',
                          prefixIcon: HugeIcons.strokeRoundedMapsGlobal01,
                          isRequired: true,
                          variant: 'filled',
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
                    prefixIcon: HugeIcons.strokeRoundedMail02,
                    isRequired: true,
                    variant: 'filled',
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'Zip code is required'
                        : null,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 32),

                  // Security Information
                  _buildSectionTitle('Security Information'),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Password',
                    controller: _passwordCtrl,
                    hintText: 'Create a strong password',
                    prefixIcon: HugeIcons.strokeRoundedLockPassword,
                    isPassword: true,
                    isRequired: true,
                    variant: 'filled',
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 8)
                        return 'Password must be at least 8 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Confirm Password',
                    controller: _confirmPasswordCtrl,
                    hintText: 'Re-enter your password',
                    prefixIcon: HugeIcons.strokeRoundedLockPassword,
                    isPassword: true,
                    isRequired: true,
                    variant: 'filled',
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Please confirm your password';
                      if (v != _passwordCtrl.text)
                        return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  CustomButton(
                    text: 'Create Account',
                    onPressed: _submit,
                    isLoading: isLoading,
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        GestureDetector(
                          onTap: isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDropdownLabel(String label, bool isRequired) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.error),
            ),
        ],
      ),
    );
  }

  Widget _buildFilledDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
    String? hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<T>(
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          hintText: hintText,
        ),
        items: items,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
