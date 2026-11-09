import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/driver_provider.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/app_theme.dart';
import 'filter_dropdown.dart';
import 'filter_input_field.dart';

class FilterSectionWidget extends StatefulWidget {
  const FilterSectionWidget({super.key});

  @override
  State<FilterSectionWidget> createState() => _FilterSectionWidgetState();
}

class _FilterSectionWidgetState extends State<FilterSectionWidget> {
  final TextEditingController _lengthController = TextEditingController();

  @override
  void dispose() {
    _lengthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverProvider>(
      builder: (context, provider, _) {
        final strings = AppStrings(provider.isBengali);

        // Keep local controller in sync if provider resets filter
        if (_lengthController.text != provider.vehicleLengthFilter && provider.vehicleLengthFilter.isEmpty) {
          _lengthController.clear();
        }

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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                            onChanged: (val) {
                              _lengthController.clear();
                              provider.setVehicleType(val);
                            },
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
                            onChanged: (val) {
                              _lengthController.clear();
                              provider.setVehicleType(val);
                            },
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

                  // Dynamic Feature-specific Filters
                  // 1. Truck / Pickup: Covered Checkbox + Conditional Length Field (Only if Covered is checked)
                  if (provider.isSelectedTruckOrPickup) ...[
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        InkWell(
                          onTap: () {
                            final next = !provider.isCoveredFilter;
                            if (!next) _lengthController.clear();
                            provider.setIsCoveredFilter(next);
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: provider.isCoveredFilter ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: provider.isCoveredFilter ? AppColors.primary : AppColors.border,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Checkbox(
                                    value: provider.isCoveredFilter,
                                    activeColor: AppColors.primary,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    onChanged: (val) {
                                      final next = val ?? false;
                                      if (!next) _lengthController.clear();
                                      provider.setIsCoveredFilter(next);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  provider.isBengali ? 'শুধু Covered গাড়ি দেখান' : 'Show Covered only',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: provider.isCoveredFilter ? AppColors.primary : AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Length input appears ONLY IF Covered is checked!
                        if (provider.isCoveredFilter)
                          SizedBox(
                            width: isWeb ? 280 : double.infinity,
                            child: TextField(
                              controller: _lengthController,
                              onChanged: (val) => provider.setVehicleLengthFilter(val),
                              decoration: InputDecoration(
                                hintText: provider.isBengali
                                    ? 'গাড়ির লম্বা অনুযায়ী খুঁজুন (যেমন: ১২ বা ১৪)'
                                    : 'Search by length (ex: 12 or 14)',
                                hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: const Icon(Icons.straighten, size: 16, color: AppColors.primary),
                                suffixIcon: provider.vehicleLengthFilter.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 16),
                                        onPressed: () {
                                          _lengthController.clear();
                                          provider.setVehicleLengthFilter('');
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                                ),
                              ),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                  ],

                  // 2. Helicopter: Air Ambulance
                  if (provider.isSelectedHelicopter) ...[
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => provider.setIsAirAmbulanceFilter(!provider.isAirAmbulanceFilter),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: provider.isAirAmbulanceFilter ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: provider.isAirAmbulanceFilter ? AppColors.primary : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: provider.isAirAmbulanceFilter,
                                activeColor: AppColors.primary,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                onChanged: (val) => provider.setIsAirAmbulanceFilter(val ?? false),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              provider.isBengali
                                  ? 'এয়ার অ্যাম্বুলেন্স লাগলে টিক দিন (Need Air Ambulance?)'
                                  : 'Need Air Ambulance?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: provider.isAirAmbulanceFilter ? AppColors.primary : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // 3. Motorcycle / Private Car: Self Driving / Rent without driver
                  if (provider.isSelectedMotorcycleOrCar) ...[
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => provider.setIsSelfDrivingFilter(!provider.isSelfDrivingFilter),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: provider.isSelfDrivingFilter ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: provider.isSelfDrivingFilter ? AppColors.primary : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: provider.isSelfDrivingFilter,
                                activeColor: AppColors.primary,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                onChanged: (val) => provider.setIsSelfDrivingFilter(val ?? false),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              provider.isBengali
                                  ? 'শুধু উইথআউট ড্রাইভার রেন্ট বা সেলফ ড্রাইভিং দেখান (Self-Driving only)'
                                  : 'Rent without driver / Self-Driving only',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: provider.isSelfDrivingFilter ? AppColors.primary : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
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
