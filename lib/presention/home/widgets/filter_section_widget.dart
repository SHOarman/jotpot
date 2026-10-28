import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/driver_provider.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/app_theme.dart';
import 'filter_dropdown.dart';
import 'filter_input_field.dart';

class FilterSectionWidget extends StatelessWidget {
  const FilterSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverProvider>(
      builder: (context, provider, _) {
        final strings = AppStrings(provider.isBengali);

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWeb = constraints.maxWidth > 768;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFFAFBFC)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (isWeb)
                    // Web View: Single Horizontal Row with all 6 filters
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Vehicle Type
                        Expanded(
                          child: FilterDropdown(
                            label: strings.filterVehicleType,
                            hint: strings.selectVehicleType,
                            value: provider.selectedVehicleType,
                            items: provider.vehicleTypes,
                            onChanged: (val) => provider.setVehicleType(val),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 2. Division
                        Expanded(
                          child: FilterDropdown(
                            label: strings.filterDivision,
                            hint: strings.selectDivision,
                            value: provider.selectedDivision,
                            items: provider.divisions,
                            onChanged: (val) => provider.setDivision(val),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 3. District (Cascading: Only active when division is selected)
                        Expanded(
                          child: FilterDropdown(
                            label: strings.filterDistrict,
                            hint: strings.selectDistrict,
                            value: provider.selectedDistrict,
                            items: provider.districts,
                            isEnabled: provider.selectedDivision != null,
                            onChanged: (val) => provider.setDistrict(val),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 4. Upazila (Cascading: Only active when district is selected)
                        Expanded(
                          child: FilterDropdown(
                            label: strings.filterUpazila,
                            hint: strings.selectUpazila,
                            value: provider.selectedUpazila,
                            items: provider.upazilas,
                            isEnabled: provider.selectedDistrict != null,
                            onChanged: (val) => provider.setUpazila(val),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 5. Union / Municipality (BD API dropdown)
                        Expanded(
                          child: FilterDropdown(
                            label: strings.filterUnion,
                            hint: provider.isLoadingUnions
                                ? (provider.isBengali ? 'লোড হচ্ছে...' : 'Loading...')
                                : strings.filterUnionHint,
                            value: provider.selectedUnion,
                            items: provider.unions,
                            isEnabled: provider.selectedUpazila != null && !provider.isLoadingUnions,
                            isLoading: provider.isLoadingUnions,
                            onChanged: (val) => provider.setUnion(val),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 6. Ward (Typeable text field)
                        Expanded(
                          child: FilterInputField(
                            label: strings.filterWard,
                            hint: strings.filterWardHint,
                            value: provider.selectedWard,
                            onChanged: (val) => provider.setWard(val),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    // Mobile View: 3 Rows of 2 Columns
                    // Row 1: Vehicle Type & Division
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: FilterDropdown(
                            label: strings.filterVehicleType,
                            hint: strings.selectVehicleType,
                            value: provider.selectedVehicleType,
                            items: provider.vehicleTypes,
                            onChanged: (val) => provider.setVehicleType(val),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilterDropdown(
                            label: strings.filterDivision,
                            hint: strings.selectDivision,
                            value: provider.selectedDivision,
                            items: provider.divisions,
                            onChanged: (val) => provider.setDivision(val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 2: District & Upazila (Cascading)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: FilterDropdown(
                            label: strings.filterDistrict,
                            hint: strings.selectDistrict,
                            value: provider.selectedDistrict,
                            items: provider.districts,
                            isEnabled: provider.selectedDivision != null,
                            onChanged: (val) => provider.setDistrict(val),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilterDropdown(
                            label: strings.filterUpazila,
                            hint: strings.selectUpazila,
                            value: provider.selectedUpazila,
                            items: provider.upazilas,
                            isEnabled: provider.selectedDistrict != null,
                            onChanged: (val) => provider.setUpazila(val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 3: Union & Ward (Typeable Text Input Fields)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: FilterDropdown(
                            label: strings.filterUnion,
                            hint: provider.isLoadingUnions
                                ? (provider.isBengali ? 'লোড হচ্ছে...' : 'Loading...')
                                : strings.filterUnionHint,
                            value: provider.selectedUnion,
                            items: provider.unions,
                            isEnabled: provider.selectedUpazila != null && !provider.isLoadingUnions,
                            isLoading: provider.isLoadingUnions,
                            onChanged: (val) => provider.setUnion(val),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilterInputField(
                            label: strings.filterWard,
                            hint: strings.filterWardHint,
                            value: provider.selectedWard,
                            onChanged: (val) => provider.setWard(val),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

