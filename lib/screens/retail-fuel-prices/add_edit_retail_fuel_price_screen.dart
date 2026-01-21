import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/components/shared/custom_button.dart';
import 'package:bdcomputing/components/shared/custom_dropdown.dart';
import 'package:bdcomputing/components/shared/custom_toggle.dart';
import 'package:bdcomputing/components/shared/section_card.dart';
import 'package:bdcomputing/components/shared/custom_text_field.dart';
import 'package:bdcomputing/models/fuel/create_retail_fuel_price.dart';
import 'package:bdcomputing/models/fuel/fuel_price.dart';
import 'package:bdcomputing/models/fuel/fuel_product.dart';
import 'package:bdcomputing/models/fuel/fuel_product_type.dart';
import 'package:bdcomputing/models/fuel/update_retail_fuel_price.dart';
import 'package:bdcomputing/providers/currencies/currency_list_provider.dart';
import 'package:bdcomputing/providers/providers.dart';
import 'package:bdcomputing/screens/auth/domain/auth_state.dart';
import 'package:bdcomputing/screens/auth/providers.dart';

class AddEditRetailFuelPriceScreen extends ConsumerStatefulWidget {
  final FuelPrice? fuelPrice;
  final List<FuelPrice> existingPrices;

  const AddEditRetailFuelPriceScreen({
    super.key,
    this.fuelPrice,
    this.existingPrices = const [],
  });

  @override
  ConsumerState<AddEditRetailFuelPriceScreen> createState() =>
      _AddEditRetailFuelPriceScreenState();
}

class _AddEditRetailFuelPriceScreenState
    extends ConsumerState<AddEditRetailFuelPriceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _currencyController = TextEditingController();
  final _minOrderController = TextEditingController();
  final _maxOrderController = TextEditingController();

  bool _isLoading = false;
  bool _supplyActive = true;
  String? _selectedFuelProductId;
  String? _selectedFuelProductTypeId;
  String? _selectedCurrencyId;

  List<FuelProduct> _allFuelProducts = [];

  // Derived filtered lists
  List<FuelProduct> get _availableFuelProducts {
    if (widget.fuelPrice != null) {
      return _allFuelProducts;
    }

    // Identify products where all types are already taken
    // For now, simpler check: show all, filter types.
    // Ideally we filter products that have NO available types.
    return _allFuelProducts;
  }

  List<FuelProductType> get _availableFuelProductTypes {
    if (_selectedFuelProductId == null) return [];

    // First filter by the selected product
    // First filter by the selected product
    final product = _allFuelProducts.firstWhere(
      (p) => p.id == _selectedFuelProductId,
      orElse: () => FuelProduct(
          id: '', 
          name: '', 
          createdAt: DateTime.now(), 
          updatedAt: DateTime.now()
      ),
    );
    
    final productTypes = product.fuelProductTypes ?? [];

    // In edit mode, user can keep current type or switch to another available one.
    // The previous logic just returned all types for the product in edit mode.
    if (widget.fuelPrice != null) {
      return productTypes; 
    }

    // Filter out types that already have a price for this product
    final takenTypeIds = widget.existingPrices
        .where((p) => p.fuelProductId == _selectedFuelProductId)
        .map((p) => p.fuelProductTypeId)
        .toSet();

    return productTypes
        .where((t) => !takenTypeIds.contains(t.id))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    if (widget.fuelPrice != null) {
      _initializeEditMode();
    }
  }

  void _initializeEditMode() {
    final price = widget.fuelPrice!;
    _selectedFuelProductId = price.fuelProductId;
    _selectedFuelProductTypeId = price.fuelProductTypeId;
    _selectedCurrencyId = price.currencyId;
    _priceController.text = price.price.toString();
    _minOrderController.text = price.minOrder.toString();
    _maxOrderController.text = price.maxOrder.toString();
    _supplyActive = price.supplyActive;
    
    // Filter logic handles types availability
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final fuelService = ref.read(fuelServiceProvider);
      ref.read(currencyServiceProvider);

      final products = await fuelService.getFuelProducts();

      if (mounted) {
        setState(() {
          _allFuelProducts = products;
          _isLoading = false;
        });
        
        if (widget.fuelPrice != null) {
          _initializeEditMode();
        }
      }
      
      // Fetch currencies separately to avoid blocking if one fails
      _fetchCurrencies();

    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }
  
  Future<void> _fetchCurrencies() async {
    try {
      final currencyService = ref.read(currencyServiceProvider);
      final currencies = await currencyService.fetchAllCurrencies();

      if (mounted) {
        setState(() {
          final authState = ref.read(authProvider);
          if (authState is Authenticated && authState.user.vendor != null) {
            _selectedCurrencyId = authState.user.vendor!.currencyId;
          }

          if (_selectedCurrencyId != null && currencies.isNotEmpty) {
            try {
              final currency =
                  currencies.firstWhere((c) => c.id == _selectedCurrencyId);
              _currencyController.text = '${currency.code} (${currency.icon})';
            } catch (_) {
              // Currency not found in list, fall back to what's in the price model if editing
              if (widget.fuelPrice?.currency != null) {
                final c = widget.fuelPrice!.currency!;
                _currencyController.text = '${c.code} (${c.icon})';
              }
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Error fetching currencies: $e');
      }
    }
  }

  // No longer needed as we fetch all types initially
  // Future<void> _fetchFuelProductTypes(String productId) async { ... }

  void _onProductChanged(String? productId) {
    if (productId == null) return;
    setState(() {
      _selectedFuelProductId = productId;
      _selectedFuelProductTypeId = null; // Reset type when product changes
      
      // Auto-select if only one type available
      final availableTypes = _availableFuelProductTypes;
      if (availableTypes.length == 1) {
        _selectedFuelProductTypeId = availableTypes.first.id;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Basic validation
    if (_selectedFuelProductId == null || _selectedFuelProductTypeId == null) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select product and type')),
        );
       return;
    }

    setState(() => _isLoading = true);
    final fuelService = ref.read(fuelServiceProvider);

    try {
      final authState = ref.read(authProvider);
      final vendorCurrencyId = (authState is Authenticated) ? authState.user.vendor?.currencyId : null;
      final currencyId = vendorCurrencyId ?? _selectedCurrencyId;

      if (currencyId == null) {
        throw Exception(
            'Currency information not found. Please ensure your vendor profile is complete.');
      }

      final price = double.tryParse(_priceController.text) ?? 0;
      final minOrder = double.tryParse(_minOrderController.text) ?? 0;
      final maxOrder = double.tryParse(_maxOrderController.text) ?? 0;

      if (widget.fuelPrice != null) {
        // Update
        final payload = UpdateRetailFuelPrice(
            fuelProductId: _selectedFuelProductId,
            fuelProductTypeId: _selectedFuelProductTypeId,
            currencyId: currencyId,
            price: price,
            minOrder: minOrder,
            maxOrder: maxOrder,
            supplyActive: _supplyActive,
        );
        
        await fuelService.updateRetailFuelPrice(
            id: widget.fuelPrice!.id, 
            payload: payload
        );
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Price updated successfully')),
           );
         }

      } else {
        // Create
        final payload = CreateRetailFuelPrice(
            fuelProductId: _selectedFuelProductId!,
            fuelProductTypeId: _selectedFuelProductTypeId!,
            currencyId: currencyId,
            price: price,
            minOrder: minOrder,
            maxOrder: maxOrder,
            supplyActive: _supplyActive,
        );
        
        await fuelService.createRetailFuelPrice(payload: payload);
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Price created successfully')),
           );
         }
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to refresh list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
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
    final isEdit = widget.fuelPrice != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Fuel Price' : 'Add Fuel Price'),
      ),
      body: _isLoading && _allFuelProducts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionCard(
                      title: 'Product Information',
                      children: [
                        CustomDropdown<String>(
                          label: 'Fuel Product',
                          value: _selectedFuelProductId,
                          items: _availableFuelProducts.map((p) => p.id).toList(),
                          itemLabel: (id) => _allFuelProducts
                              .firstWhere((p) => p.id == id,
                                  orElse: () => FuelProduct(
                                      id: '',
                                      name: '',
                                      createdAt: DateTime.now(),
                                      updatedAt: DateTime.now()))
                              .name,
                          onChanged: isEdit ? null : _onProductChanged,
                          validator: (v) => v == null ? 'Required' : null,
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        CustomDropdown<String>(
                          label: 'Product Type',
                          value: _selectedFuelProductTypeId,
                          items: _availableFuelProductTypes.map((t) => t.id).toList(),
                          itemLabel: (id) => _availableFuelProductTypes
                              .firstWhere((t) => t.id == id,
                                  orElse: () => FuelProductType(
                                      id: '',
                                      name: '',
                                      price: 0,
                                      createdAt: DateTime.now(),
                                      updatedAt: DateTime.now(),
                                      isActive: true))
                              .name,
                          onChanged: isEdit
                              ? null
                              : (v) =>
                                  setState(() => _selectedFuelProductTypeId = v),
                          validator: (v) => v == null ? 'Required' : null,
                          isRequired: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      title: 'Pricing & Availability',
                      children: [
                        CustomTextField(
                          controller: _currencyController,
                          label: 'Currency',
                          readOnly: true,
                          hintText: 'Loading currency...',
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _priceController,
                          label: 'Price per Litre',
                          keyboardType: TextInputType.number,
                          isRequired: true,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (double.tryParse(v) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _minOrderController,
                                label: 'Min Order',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                controller: _maxOrderController,
                                label: 'Max Order',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomToggle(
                          title: 'Supply Active',
                          subtitle: 'Turn off to mark as out of stock',
                          value: _supplyActive,
                          onChanged: (v) => setState(() => _supplyActive = v),
                          dense: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: isEdit ? 'Update Price' : 'Add Price',
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
