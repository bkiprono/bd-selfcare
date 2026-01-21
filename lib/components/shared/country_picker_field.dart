import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/components/shared/custom_text_field.dart';
import 'package:bdcomputing/components/shared/searchable_picker.dart';
import 'package:bdcomputing/core/styles.dart';
import 'package:bdcomputing/models/common/country.dart';
import 'package:bdcomputing/providers/countries_providers.dart';

class CountryPickerField extends ConsumerWidget {
  final Country? selectedCountry;
  final ValueChanged<Country?> onSelected;
  final String label;
  final bool isRequired;

  const CountryPickerField({
    super.key,
    required this.selectedCountry,
    required this.onSelected,
    this.label = 'Country of Origin',
    this.isRequired = false,
    this.validator,
    this.hint = 'Select country',
    this.controller,
  });

  final String? Function(String?)? validator;
  final String hint;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(countriesProvider);

    return countriesAsync.when(
      data: (countries) => CustomTextField(
        label: label,
        hintText: hint,
        controller: controller ?? TextEditingController(text: selectedCountry?.name ?? ''),
        readOnly: true,
        isRequired: isRequired,
        validator: validator,
        onTap: () async {
          final selected = await SearchablePicker.show<Country>(
            context: context,
            title: 'Select Country',
            items: countries,
            searchMatcher: (item, query) =>
                item.name.toLowerCase().contains(query),
            itemBuilder: (country) => ListTile(
              title: Text(country.name),
              subtitle: Text(country.code),
              trailing: selectedCountry?.id == country.id
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.pop(context, country),
            ),
          );
          if (selected != null) {
            onSelected(selected);
          }
        },
        suffixIcon: const Icon(Icons.keyboard_arrow_down),
      ),
      loading: () => CustomTextField(
        label: label,
        hintText: 'Loading countries...',
        controller: controller ?? TextEditingController(),
        readOnly: true,
        isRequired: isRequired,
        validator: validator,
      ),
      error: (_, _) => CustomTextField(
        label: label,
        hintText: 'Error loading countries',
        controller: controller ?? TextEditingController(),
        readOnly: true,
        isRequired: isRequired,
        validator: validator,
      ),
    );
  }
}
