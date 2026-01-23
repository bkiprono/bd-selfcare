import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/models/common/country.dart';
import 'package:bdcomputing/models/common/currency.dart';
import 'package:bdcomputing/models/common/vendor.dart';
import 'package:bdcomputing/providers/currencies/currency_list_provider.dart';
import 'package:bdcomputing/components/shared/section_card.dart';
import 'package:bdcomputing/components/shared/custom_text_field.dart';
import 'package:bdcomputing/components/shared/custom_button.dart';
import 'package:bdcomputing/components/shared/country_picker_field.dart';
import 'package:bdcomputing/components/shared/custom_toggle.dart';
import 'package:bdcomputing/components/shared/searchable_picker.dart';
import 'package:bdcomputing/components/shared/custom_picker_field.dart';
import 'package:bdcomputing/screens/auth/auth_provider.dart';
import 'package:bdcomputing/core/styles.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Business Information
  final _businessNameCtrl = TextEditingController();
  final _businessEmailCtrl = TextEditingController();
  final _businessPhoneCtrl = TextEditingController();

  // Business Address
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipCodeCtrl = TextEditingController();
  Country? _selectedCountry;

  // Contact Person (Admin)
  final _contactNameCtrl = TextEditingController();
  final _contactEmailCtrl = TextEditingController();
  final _contactPhoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // Account Settings
  bool _fuelVendor = true;
  bool _productVendor = false;
  Currency? _selectedCurrency;

  bool _submitting = false;

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _businessEmailCtrl.dispose();
    _businessPhoneCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCodeCtrl.dispose();
    _contactNameCtrl.dispose();
    _contactEmailCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  static void _dummyOnTap() {}

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate country selection
    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select your country'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Validate currency selection
    if (_selectedCurrency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select your preferred currency'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Validate at least one supply type is selected
    if (!_fuelVendor && !_productVendor) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one supply type (Fuel Vendor or Product Vendor)'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final service = ref.read(authServiceProvider);

      final vendor = VendorRegister(
        name: _businessNameCtrl.text,
        email:_businessEmailCtrl.text,
        phone: _businessPhoneCtrl.text,
        city: _cityCtrl.text,
        street: _streetCtrl.text,
        state: _stateCtrl.text,
        zipCode: _zipCodeCtrl.text,
        contactPersonName: _contactNameCtrl.text,
        contactPersonPhone: _contactPhoneCtrl.text,
        contactPersonEmail: _contactEmailCtrl.text,
        currencyId: _selectedCurrency!.currencyId,
        fuelVendor: _fuelVendor,
        productVendor: _productVendor,
        password: _passwordCtrl.text,
        countryId: _selectedCountry!.id,
      );

      await service.signup(vendor);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created. Please log in.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(e.toString())),
            ],
          ),
          backgroundColor: Colors.red[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final isLoading = _submitting || state is AuthLoading;

    // Responsive: get screen width/height
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final isSmall = width < 400;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Header Section
            Container(
              width: double.infinity,
              height: 250,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accent,
                    AppColors.secondaryDark,
                    AppColors.secondary,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -20,
                    left: -20,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    right: -30,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (Navigator.canPop(context))
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          const Spacer(),
                          const Text(
                            'Partner Registration',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Join BD Work OS Program and grow your business today.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form Section
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 12.0 : 20.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
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
                                keyboardType: TextInputType.phone,
                              ),
                            ],
                          ),

                          SectionCard(
                            title: 'Business Address',
                            children: [
                              CountryPickerField(
                                selectedCountry: _selectedCountry,
                                onSelected: (c) =>
                                    setState(() => _selectedCountry = c),
                                isRequired: true,
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
                            title: 'Contact Person (Admin)',
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
                              const SizedBox(height: 16),
                              CustomTextField(
                                label: 'Password',
                                controller: _passwordCtrl,
                                hintText: 'Create a strong password',
                                prefixIcon: Icons.lock_outline,
                                isPassword: true,
                                isRequired: true,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Password is required'
                                    : v.length < 8
                                        ? 'Password must be at least 8 characters'
                                        : null,
                              ),
                            ],
                          ),

                          SectionCard(
                            title: 'Account Type',
                            children: [
                              ref.watch(currenciesFutureProvider).when(
                                    data: (currencies) => CustomPickerField(
                                      label: 'Preferred Currency',
                                      value: _selectedCurrency != null
                                          ? '${_selectedCurrency!.icon} ${_selectedCurrency!.name} (${_selectedCurrency!.code})'
                                          : '',
                                      hintText: 'Select your preferred currency',
                                      prefixIcon: Icons.attach_money,
                                      isRequired: true,
                                      onTap: isLoading
                                          ? () {}
                                          : () async {
                                              final selected =
                                                  await SearchablePicker.show<
                                                      Currency>(
                                                context: context,
                                                title: 'Select Currency',
                                                items: currencies,
                                                itemBuilder: (currency) {
                                                  final isSelected =
                                                      _selectedCurrency
                                                              ?.currencyId ==
                                                          currency.currencyId;
                                                  return ListTile(
                                                    leading: Text(
                                                      currency.icon,
                                                      style: const TextStyle(
                                                          fontSize: 24),
                                                    ),
                                                    title: Text(currency.name),
                                                    subtitle:
                                                        Text(currency.code),
                                                    trailing: isSelected
                                                        ? const Icon(
                                                            Icons.check_circle,
                                                            color: AppColors
                                                                .primary,
                                                          )
                                                        : null,
                                                    onTap: () => Navigator.of(context).pop(currency),
                                                  );
                                                },
                                                searchMatcher:
                                                    (currency, query) {
                                                  return currency.name
                                                          .toLowerCase()
                                                          .contains(query) ||
                                                      currency.code
                                                          .toLowerCase()
                                                          .contains(query);
                                                },
                                              );
                                              if (selected != null) {
                                                setState(() {
                                                  _selectedCurrency = selected;
                                                });
                                              }
                                            },
                                    ),
                                    loading: () => const CustomPickerField(
                                      label: 'Preferred Currency',
                                      value: '',
                                      hintText: 'Loading currencies...',
                                      prefixIcon: Icons.attach_money,
                                      isLoading: true,
                                      onTap: _dummyOnTap,
                                    ),
                                    error: (error, stack) => CustomPickerField(
                                      label: 'Preferred Currency',
                                      value: '',
                                      hintText: 'Failed to load currencies',
                                      prefixIcon: Icons.error_outline,
                                      errorText: 'Tap to retry',
                                      onTap: () => ref.refresh(currenciesFutureProvider),
                                    ),
                                  ),
                              const SizedBox(height: 16),
                              CustomToggle(
                                title: 'Fuel Vendor',
                                subtitle: 'Provide petroleum products',
                                value: _fuelVendor,
                                onChanged: (val) {
                                  if (!isLoading) {
                                    setState(() => _fuelVendor = val);
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              CustomToggle(
                                title: 'Product Vendor',
                                subtitle: 'Sell general products',
                                value: _productVendor,
                                onChanged: (val) {
                                  if (!isLoading) {
                                    setState(() => _productVendor = val);
                                  }
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          CustomButton(
                            text: 'Create Account',
                            onPressed: _submit,
                            isLoading: isLoading,
                          ),

                          const SizedBox(height: 24),

                          // Login redirect
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    color: Colors.grey[600],
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  
}
