import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/components/shared/custom_label.dart';
import 'package:bdcomputing/components/shared/header.dart';
import 'package:bdcomputing/core/styles.dart';
import 'package:bdcomputing/enums/product_enums.dart';
import 'package:bdcomputing/models/common/country.dart';
import 'package:bdcomputing/models/products/manage_product.dart';
import 'package:bdcomputing/models/products/product_category.dart';
import 'package:bdcomputing/models/products/product_subcategory.dart';
import 'package:bdcomputing/providers/providers.dart';
import 'package:bdcomputing/screens/auth/domain/auth_state.dart';
import 'package:bdcomputing/screens/auth/providers.dart';
import 'package:bdcomputing/screens/products/products_provider.dart';
import 'package:bdcomputing/components/shared/custom_button.dart';
import 'package:bdcomputing/components/shared/custom_dropdown.dart';
import 'package:bdcomputing/components/shared/country_picker_field.dart';
import 'package:bdcomputing/components/shared/custom_radio_group.dart';
import 'package:bdcomputing/components/shared/custom_text_field.dart';
import 'package:bdcomputing/components/shared/custom_toggle.dart';
import 'package:bdcomputing/components/shared/searchable_picker.dart';
import 'package:bdcomputing/components/shared/section_card.dart';
import 'package:bdcomputing/models/products/product.dart';

class ManageProductScreen extends ConsumerStatefulWidget {
  final String? productId;
  const ManageProductScreen({super.key, this.productId});

  @override
  ConsumerState<ManageProductScreen> createState() =>
      _ManageProductScreenState();
}

class _ManageProductScreenState extends ConsumerState<ManageProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _excerptCtrl = TextEditingController();
  final _countInStockCtrl = TextEditingController();
  final _minStockAlertCtrl = TextEditingController();
  final _minOrderCountCtrl = TextEditingController();
  final _unitPriceCtrl = TextEditingController();
  final _sellingPriceCtrl = TextEditingController();
  final _discountedPriceCtrl = TextEditingController();

  final _countryCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _subcategoryCtrl = TextEditingController();

  final _weightCtrl = TextEditingController();

  // Packaging
  final _heightCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  final _lengthCtrl = TextEditingController();

  // Logistics
  final _freeReturnDaysCtrl = TextEditingController();
  final _shippingDaysCtrl = TextEditingController();
  final _pickupDaysCtrl = TextEditingController();
  final _deliveryDaysCtrl = TextEditingController();
  bool _freeShipping = false;

  bool _isPublished = true;
  String _productAvailability = ProductAvailability.global.value;
  String _weightUnit = 'kg';
  String _packagingUnit = 'cm';

  Country? _selectedCountry;
  ProductCategory? _selectedCategory;
  ProductSubCategory? _selectedSubCategory;

  bool _isSubmitting = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _fetchProductDetails();
    } else {
      _minOrderCountCtrl.text = '1';
      _freeReturnDaysCtrl.text = '0';
      _shippingDaysCtrl.text = '0';
      _pickupDaysCtrl.text = '0';
      _deliveryDaysCtrl.text = '0';
    }
    _unitPriceCtrl.addListener(_updateSellingPrice);
  }

  Future<void> _fetchProductDetails() async {
    setState(() => _isLoading = true);
    try {
      final product = await ref.read(
        productDetailsProvider(widget.productId!).future,
      );
      if (product != null && mounted) {
        _patchForm(product);
      }
    } catch (e) {
      _showError('Failed to load product details: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _patchForm(Product product) {
    _nameCtrl.text = product.name;
    _descriptionCtrl.text = product.description;
    _excerptCtrl.text = product.excerpt;
    _countInStockCtrl.text = product.countInStock.toString();
    _minStockAlertCtrl.text = product.minStockAlert.toString();
    _minOrderCountCtrl.text = product.minOrderCount.toString();
    _unitPriceCtrl.text = product.unitPrice.toString();
    _sellingPriceCtrl.text = product.sellingPrice.toString();
    _discountedPriceCtrl.text =
        product.discountedPrice > 0 ? product.discountedPrice.toString() : '';
    _weightCtrl.text = product.weight.toString();
    _weightUnit = product.weightUnit;
    _isPublished = product.isPublished;
    _productAvailability = product.productAvailability.value;

    _selectedCountry = product.countryOfOrigin;
    _countryCtrl.text = _selectedCountry?.name ?? '';
    _selectedCategory = product.category;
    _categoryCtrl.text = _selectedCategory?.name ?? '';
    _selectedSubCategory = product.subCategory;
    _subcategoryCtrl.text = _selectedSubCategory?.name ?? '';

    _freeReturnDaysCtrl.text = product.freeReturnDays.toString();
    _shippingDaysCtrl.text = product.shippingDays.toString();
    _pickupDaysCtrl.text = product.pickupDays.toString();
    _deliveryDaysCtrl.text = product.deliveryDays.toString();
    _freeShipping = product.freeShipping;

    _heightCtrl.text = product.packaging.height.toString();
    _widthCtrl.text = product.packaging.width.toString();
    _lengthCtrl.text = product.packaging.length.toString();
    _packagingUnit = product.packaging.unit;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _excerptCtrl.dispose();
    _countInStockCtrl.dispose();
    _minStockAlertCtrl.dispose();
    _minOrderCountCtrl.dispose();
    _unitPriceCtrl.dispose();
    _sellingPriceCtrl.dispose();
    _weightCtrl.dispose();
    _countryCtrl.dispose();
    _categoryCtrl.dispose();
    _subcategoryCtrl.dispose();
    _heightCtrl.dispose();
    _widthCtrl.dispose();
    _lengthCtrl.dispose();
    _freeReturnDaysCtrl.dispose();
    _shippingDaysCtrl.dispose();
    _pickupDaysCtrl.dispose();
    _deliveryDaysCtrl.dispose();
    _unitPriceCtrl.removeListener(_updateSellingPrice);
    super.dispose();
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final authState = ref.read(authProvider);
      final user = authState is Authenticated ? authState.user : null;

      if (user == null || user.vendorId == null) {
        _showError('Vendor information not found');
        return;
      }

      final product = CreateProductModel(
        isPublished: _isPublished,
        countryOfOriginId: _selectedCountry!.id,
        vendorId: user.vendorId!,
        currencyId: user.vendor?.currencyId,
        name: _nameCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        categoryId: _selectedCategory!.id,
        subCategoryId: _selectedSubCategory!.id,
        countInStock: int.parse(_countInStockCtrl.text),
        minStockAlert: int.tryParse(_minStockAlertCtrl.text) ?? 0,
        minOrderCount: int.tryParse(_minOrderCountCtrl.text) ?? 1,
        productAvailability: _productAvailability,
        unitPrice: double.parse(_unitPriceCtrl.text),
        sellingPrice: double.parse(_sellingPriceCtrl.text),
        discountedPrice: double.tryParse(_discountedPriceCtrl.text),
        excerpt: _excerptCtrl.text.trim(),
        weight: double.parse(_weightCtrl.text),
        weightUnit: _weightUnit,
        packaging: ProductPackaging(
          height: double.parse(_heightCtrl.text),
          width: double.parse(_widthCtrl.text),
          length: double.parse(_lengthCtrl.text),
          unit: _packagingUnit,
        ),
        freeReturnDays: int.tryParse(_freeReturnDaysCtrl.text) ?? 0,
        shippingDays: int.tryParse(_shippingDaysCtrl.text) ?? 0,
        pickupDays: int.tryParse(_pickupDaysCtrl.text) ?? 0,
        deliveryDays: int.tryParse(_deliveryDaysCtrl.text) ?? 0,
        freeShipping: _freeShipping,
      );

      if (!product.isValid()) {
        _showError('Please fill all required fields correctly');
        return;
      }

      final success = widget.productId == null
          ? await ref.read(productsProvider.notifier).createProduct(product)
          : await ref
                .read(productsProvider.notifier)
                .updateProduct(widget.productId!, product);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.productId == null
                  ? 'Product created successfully!'
                  : 'Product updated successfully!',
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        final error = ref.read(productsProvider).error;
        _showError(
          error ??
              (widget.productId == null
                  ? 'Failed to create product'
                  : 'Failed to update product'),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateSellingPrice() {
    final unitPrice = double.tryParse(_unitPriceCtrl.text) ?? 0.0;
    if (unitPrice <= 0) {
      _sellingPriceCtrl.text = '0.00';
      return;
    }

    final authState = ref.read(authProvider);
    double commissionRate = 0.0;
    bool isPercentage = false;

    if (authState is Authenticated &&
        authState.user.vendor?.country?.commissionRates?.product != null) {
      final productCommission =
          authState.user.vendor!.country!.commissionRates!.product!;
      commissionRate = productCommission.rate.toDouble();
      isPercentage = productCommission.isPercentage;
    }
    double sellingPrice;
    if (isPercentage) {
      sellingPrice = unitPrice * (commissionRate / 100) + unitPrice;
    } else {
      sellingPrice = unitPrice + commissionRate;
    }

    _sellingPriceCtrl.text = sellingPrice.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Header(
          title: widget.productId == null ? 'Create Product' : 'Edit Product',
          showCurrencyIcon: false,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SectionCard(
                    title: 'Basic Information',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isPublished ? 'Live' : 'Draft',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _isPublished ? Colors.green : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Switch(
                          value: _isPublished,
                          onChanged: (val) =>
                              setState(() => _isPublished = val),
                          activeThumbColor: Colors.white,
                          activeTrackColor: Colors.green,
                        ),
                      ],
                    ),
                    children: [
                        CustomTextField(
                          controller: _nameCtrl,
                          label: 'Product Name',
                          hintText: 'Enter product name',
                          isRequired: true,
                          validator: (v) => v?.isEmpty ?? true
                              ? 'Product name is required'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _excerptCtrl,
                          label: 'Short Description',
                          hintText: 'Brief product description',
                          maxLines: 2,
                          isRequired: true,
                          validator: (v) => v?.isEmpty ?? true
                              ? 'Short description is required'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _descriptionCtrl,
                          label: 'Full Description',
                          hintText: 'Detailed product description',
                          maxLines: 5,
                          isRequired: true,
                          validator: (v) => v?.isEmpty ?? true
                              ? 'Description is required'
                              : null,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'Category & Origin',
                    children: [
                      _buildCategoryPicker(),
                      const SizedBox(height: 16),
                      if (_selectedCategory != null) ...[
                        _buildSubCategoryPicker(),
                        const SizedBox(height: 16),
                      ],
                      CountryPickerField(
                        selectedCountry: _selectedCountry,
                        controller: _countryCtrl,
                        isRequired: true,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        onSelected: (val) {
                          setState(() {
                            _selectedCountry = val;
                            _countryCtrl.text = val?.name ?? '';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'Pricing',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _unitPriceCtrl,
                              label: 'Unit Price',
                              hintText: '0.00',
                              isRequired: true,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                     decimal: true,
                                  ),
                              validator: (v) {
                                if (v?.isEmpty ?? true) return 'Required';
                                if (double.tryParse(v!) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _sellingPriceCtrl,
                              label: 'Selling Price',
                              hintText: '0.00',
                              readOnly: true,
                              isRequired: true,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                     decimal: true,
                                  ),
                              validator: (v) {
                                if (v?.isEmpty ?? true) return 'Required';
                                if (double.tryParse(v!) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _discountedPriceCtrl,
                        label: 'Discounted Price (Optional)',
                        hintText: '0.00',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'Inventory',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _countInStockCtrl,
                              label: 'Stock Count',
                              hintText: '0',
                              isRequired: true,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v?.isEmpty ?? true) return 'Required';
                                if (int.tryParse(v!) == null) return 'Invalid';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _minStockAlertCtrl,
                              label: 'Min Stock Alert',
                              hintText: '0',
                              isRequired: true,
                              keyboardType: TextInputType.number,
                              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _minOrderCountCtrl,
                        label: 'Min Order Count',
                        hintText: '1',
                        isRequired: true,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v?.isEmpty ?? true) return 'Required';
                          final val = int.tryParse(v!);
                          if (val == null) return 'Invalid number';
                          if (val < 1) return 'Must be at least 1';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomRadioGroup<String>(
                        label: 'Product Availability',
                        selectedValue: _productAvailability,
                        isRequired: true,
                        options: ProductAvailability.values.map((availability) {
                          return CustomRadioOption<String>(
                            value: availability.value,
                            label: availability.label,
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _productAvailability = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'Shipping Details',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: CustomTextField(
                              controller: _weightCtrl,
                              label: 'Weight',
                              hintText: '0.0',
                              keyboardType: TextInputType.number,
                              isRequired: true,
                              validator: (v) {
                                if (v?.isEmpty ?? true) return 'Required';
                                if (double.tryParse(v!) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomDropdown<String>(
                              label: 'Unit',
                              value: _weightUnit,
                              items: const ['kg', 'g', 'lb', 'oz'],
                              itemLabel: (val) => val,
                              onChanged: (val) =>
                                  setState(() => _weightUnit = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const CustomLabel(
                        text: 'Package Dimensions',
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _lengthCtrl,
                              label: 'Length',
                              hintText: '0',
                              keyboardType: TextInputType.number,
                              isRequired: true,
                              validator: (v) {
                                if (v?.isEmpty ?? true) return 'Required';
                                if (double.tryParse(v!) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomTextField(
                              controller: _widthCtrl,
                              label: 'Width',
                              hintText: '0',
                              keyboardType: TextInputType.number,
                              isRequired: true,
                              validator: (v) {
                                if (v?.isEmpty ?? true) return 'Required';
                                if (double.tryParse(v!) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomTextField(
                              controller: _heightCtrl,
                              label: 'Height',
                              hintText: '0',
                              keyboardType: TextInputType.number,
                              isRequired: true,
                              validator: (v) {
                                if (v?.isEmpty ?? true) return 'Required';
                                if (double.tryParse(v!) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CustomDropdown<String>(
                        label: 'Unit',
                        value: _packagingUnit,
                        items: const ['cm', 'in', 'm'],
                        itemLabel: (val) => val,
                        onChanged: (val) =>
                            setState(() => _packagingUnit = val!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'Logistics & Policies',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _freeReturnDaysCtrl,
                              label: 'Free Return Days',
                              hintText: '0',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _shippingDaysCtrl,
                              label: 'Shipping Days',
                              hintText: '0',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _pickupDaysCtrl,
                              label: 'Pickup Days',
                              hintText: '0',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomTextField(
                              controller: _deliveryDaysCtrl,
                              label: 'Delivery Days',
                              hintText: '0',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomToggle(
                        title: 'Free Shipping',
                        subtitle: 'Enable free shipping for this product',
                        value: _freeShipping,
                        onChanged: (val) => setState(() => _freeShipping = val),
                        dense: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: widget.productId == null
                        ? 'Create Product'
                        : 'Update Product',
                    isLoading: _isSubmitting,
                    onPressed: _submitProduct,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryPicker() {
    final categoriesAsync = ref.watch(productCategoriesListProvider);
    return categoriesAsync.when(
      data: (categories) => CustomTextField(
        label: 'Category',
        hintText: 'Select category',
        controller: _categoryCtrl,
        readOnly: true,
        isRequired: true,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        onTap: () async {
          final selected = await SearchablePicker.show<ProductCategory>(
            context: context,
            title: 'Select Category',
            items: categories,
            searchMatcher: (item, query) =>
                item.name.toLowerCase().contains(query),
            itemBuilder: (category) => ListTile(
              title: Text(category.name),
              subtitle: Text(category.description),
              trailing: _selectedCategory?.id == category.id
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.pop(context, category),
            ),
          );
          if (selected != null) {
            setState(() {
              _selectedCategory = selected;
              _categoryCtrl.text = selected.name;
              _selectedSubCategory = null;
              _subcategoryCtrl.clear();
            });
          }
        },
        suffixIcon: const Icon(Icons.keyboard_arrow_down),
      ),
      loading: () => CustomTextField(
        label: 'Category',
        hintText: 'Loading categories...',
        controller: _categoryCtrl,
        readOnly: true,
        isRequired: true,
      ),
      error: (_, _) => CustomTextField(
        label: 'Category',
        hintText: 'Error loading categories',
        controller: _categoryCtrl,
        readOnly: true,
        isRequired: true,
      ),
    );
  }

  Widget _buildSubCategoryPicker() {
    final subCategories = _selectedCategory?.subCategories ?? [];
    return CustomTextField(
      label: 'Subcategory',
      hintText: 'Select subcategory',
      controller: _subcategoryCtrl,
      readOnly: true,
      isRequired: true,
      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      onTap: subCategories.isEmpty
          ? null
          : () async {
              final selected = await SearchablePicker.show<ProductSubCategory>(
                context: context,
                title: 'Select Subcategory',
                items: subCategories,
                searchMatcher: (item, query) =>
                    item.name.toLowerCase().contains(query),
                itemBuilder: (subCategory) => ListTile(
                  title: Text(subCategory.name),
                  subtitle: Text(subCategory.description),
                  trailing: _selectedSubCategory?.id == subCategory.id
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.pop(context, subCategory),
                ),
              );
              if (selected != null) {
                setState(() {
                  _selectedSubCategory = selected;
                  _subcategoryCtrl.text = selected.name;
                });
              }
            },
      suffixIcon: const Icon(Icons.keyboard_arrow_down),
    );
  }
}

