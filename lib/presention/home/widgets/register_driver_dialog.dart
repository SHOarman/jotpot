import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/driver_provider.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/union_api_service.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/app_theme.dart';

import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import '../../../core/models/vehicle_type_model.dart';
import '../../../core/models/global_settings_model.dart';
import 'bkash_payment_sheet.dart';
class RegisterDriverDialog extends StatefulWidget {
  const RegisterDriverDialog({super.key});

  @override
  State<RegisterDriverDialog> createState() => _RegisterDriverDialogState();
}

class _RegisterDriverDialogState extends State<RegisterDriverDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _modelController = TextEditingController();
  final _registrationNoController = TextEditingController();
  final _wardController = TextEditingController();

  int _selectedDurationDays = 30;
  final _transactionIdController = TextEditingController();
  final _paymentPhoneController = TextEditingController();
  // Dynamic vehicle-specific controllers
  final _seatingCapacityController = TextEditingController();
  final _vehicleLengthController = TextEditingController();
  final _vehicleCapacityController = TextEditingController();

  // Feature checkboxes
  bool _isCoveredTruck = false;
  bool _isAirAmbulance = false;
  bool _isSelfDriving = false;

  // Selection states
  String? _selectedVehicle;
  String? _selectedDivision;
  String? _selectedDistrict;
  String? _selectedUpazila;
  String? _selectedUnion; // Union dropdown value
  String? _validationError;

  // Union API state
  List<String> _availableUnions = [];
  bool _isLoadingUnions = false;

  bool get _isBusOrMiniBus {
    if (_selectedVehicle == null) return false;
    final v = _selectedVehicle!.trim().toLowerCase();
    final en = AppStrings.translateVehicleTypeStatic(_selectedVehicle!, false).toLowerCase().trim();
    if (v.contains('মাইক্রোবাস') || v.contains('মাইক্রো বাস') || en.contains('micro')) return false;
    return v == 'বাস' ||
        v.contains('মিনি বাস') ||
        v.contains('মিনিবাস') ||
        en == 'bus' ||
        en == 'mini bus' ||
        en == 'minibus';
  }

  bool get _isTruck {
    if (_selectedVehicle == null) return false;
    final v = _selectedVehicle!.trim().toLowerCase();
    final en = AppStrings.translateVehicleTypeStatic(_selectedVehicle!, false).toLowerCase().trim();
    return v.contains('ট্রাক') || en.contains('truck');
  }

  bool get _isHelicopter {
    if (_selectedVehicle == null) return false;
    final v = _selectedVehicle!.trim().toLowerCase();
    final en = AppStrings.translateVehicleTypeStatic(_selectedVehicle!, false).toLowerCase().trim();
    return v.contains('হেলিকপ্টার') || en.contains('helicopter');
  }

  bool get _isMotorcycle {
    if (_selectedVehicle == null) return false;
    final v = _selectedVehicle!.trim().toLowerCase();
    final en = AppStrings.translateVehicleTypeStatic(_selectedVehicle!, false).toLowerCase().trim();
    return (v.contains('মোটরসাইকেল') || v.contains('মোটর সাইকেল') || en == 'motorcycle') &&
        !v.contains('ইজি বাইক') &&
        !v.contains('ইজিবাইক');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _modelController.dispose();
    _registrationNoController.dispose();
    _wardController.dispose();
    _seatingCapacityController.dispose();
    _vehicleLengthController.dispose();
    _vehicleCapacityController.dispose();
    _scrollController.dispose();
    _transactionIdController.dispose();
    _paymentPhoneController.dispose();
    super.dispose();
  }

  bool _isSubmitting = false;

  /// Fetch union list from BD API for the given upazila.
  Future<void> _fetchUnions(String upazila) async {
    setState(() {
      _isLoadingUnions = true;
      _selectedUnion = null;
      _availableUnions = [];
    });
    try {
      final unions = await UnionApiService.getUnions(
        divisionBn: _selectedDivision ?? '',
        districtBn: _selectedDistrict ?? '',
        upazilaName: upazila,
      );
      if (mounted) {
        setState(() {
          _availableUnions = unions;
          _isLoadingUnions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _availableUnions = [];
          _isLoadingUnions = false;
        });
      }
    }
  }

  void _submitForm(AppStrings strings) async {
    setState(() => _validationError = null);

    if (_formKey.currentState!.validate()) {
      if (_selectedVehicle == null) {
        setState(() => _validationError = strings.vehicleTypeRequired);
        return;
      }
      if (_selectedDivision == null) {
        setState(() => _validationError = strings.divisionRequired);
        return;
      }

      final provider = Provider.of<DriverProvider>(context, listen: false);
      final settings = provider.globalSettings;

      // Find VehicleTypeModel
      VehicleTypeModel? vType;
      if (provider.vehicleTypeModels.isNotEmpty) {
        final matches = provider.vehicleTypeModels.where(
          (v) =>
              v.name.toLowerCase().trim() == _selectedVehicle!.toLowerCase().trim() ||
              AppStrings.areSameVehicleType(v.name, _selectedVehicle!),
        );
        if (matches.isNotEmpty) {
          vType = matches.first;
        }
      }

      final bool requiresPayment = (vType?.monthlyFee ?? 0) > 0;
      final num monthlyFee = vType?.monthlyFee ?? 0;
      final num vehicleDiscount = vType?.discountValue ?? 0;
      final String discountType = vType?.discountType ?? 'percentage';

      num durationDiscount = 0;
      if (_selectedDurationDays == 90) {
        durationDiscount = settings.discount3Months;
      } else if (_selectedDurationDays == 180) {
        durationDiscount = settings.discount6Months;
      } else if (_selectedDurationDays == 365) {
        durationDiscount = settings.discount1Year;
      }

      final int calculatedAmount = requiresPayment
          ? FirebaseService.calculateRenewalAmount(
              monthlyFee: monthlyFee,
              durationDays: _selectedDurationDays,
              vehicleDiscount: vehicleDiscount,
              discountType: discountType,
              durationDiscount: durationDiscount,
            )
          : 0;

      // Validate payment if required
      if (requiresPayment) {
        if (!settings.automatedPayment) {
          if (_transactionIdController.text.trim().isEmpty) {
            setState(() => _validationError = strings.isBn
                ? 'অনুগ্রহ করে পেমেন্টের ট্রানজেকশন আইডি (TrxID) লিখুন!'
                : 'Please enter transaction ID (TrxID)!');
            return;
          }
        } else {
          if (_transactionIdController.text.trim().isEmpty) {
            setState(() => _validationError = strings.isBn
                ? 'অনুগ্রহ করে প্রথমে বিকাশ দিয়ে পেমেন্ট সম্পন্ন করুন!'
                : 'Please complete payment via bKash first!');
            return;
          }
        }
      }
      setState(() => _isSubmitting = true);

      try {
        await FirebaseService.registerDriver(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          vehicleType: _selectedVehicle!,
          vehicleModel: _modelController.text.trim(),
          vehicleRegNumber: _registrationNoController.text.trim(),
          division: _selectedDivision ?? 'ঢাকা',
          district: _selectedDistrict ?? _selectedDivision ?? 'ঢাকা',
          upazila: _selectedUpazila ?? '',
          union: _selectedUnion ?? '',
          ward: _wardController.text.trim(),
          transactionId: requiresPayment
              ? _transactionIdController.text.trim()
              : 'FREE_REGISTRATION',
          durationDays: requiresPayment ? _selectedDurationDays : 3650,
          amount: calculatedAmount,
          autoPay: settings.automatedPayment,
          isCovered: _isCoveredTruck,
          isAirAmbulance: _isAirAmbulance,
          isSelfDriving: _isSelfDriving,
          seatingCapacity: _seatingCapacityController.text.trim(),
          vehicleLength: _vehicleLengthController.text.trim(),
          vehicleCapacity: _vehicleCapacityController.text.trim(),
        );
        if (!mounted) return;
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.regSuccessSnackbar),
            backgroundColor: const Color(0xFF059669),
            duration: const Duration(seconds: 4),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
          _validationError = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DriverProvider>(context);
    final strings = AppStrings.of(context);

    // Cascading district options based on selected division
    final List<String> availableDistricts = _selectedDivision != null
        ? provider.getDistrictsForDivision(_selectedDivision!)
        : <String>[];

    // Cascading upazila options based on selected district
    final List<String> availableUpazilas =
        (_selectedDivision != null && _selectedDistrict != null)
            ? provider.getUpazilasForDistrict(
                _selectedDivision!, _selectedDistrict!)
            : <String>[];

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog Header: Title & Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.regDialogTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            strings.regDialogSubtitle,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF94A3B8),
                        size: 22,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Scrollable Form Body
                Flexible(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. পুরো নাম
                          _buildFieldLabel(strings.driverName),
                          const SizedBox(height: 6),
                          _buildTextInput(
                            controller: _nameController,
                            hint: strings.driverNamePlaceholder,
                            validator: (v) => v == null || v.isEmpty
                                ? strings.driverNamePlaceholder
                                : null,
                          ),
                          const SizedBox(height: 14),

                          // 2. ফোন নম্বর
                          _buildFieldLabel(strings.mobileNumber),
                          const SizedBox(height: 6),
                          _buildTextInput(
                            controller: _phoneController,
                            hint: strings.phonePlaceholder,
                            keyboardType: TextInputType.phone,
                            validator: (v) => v == null || v.isEmpty
                                ? strings.phonePlaceholder
                                : null,
                          ),
                          const SizedBox(height: 14),

                          // 3. গাড়ির ধরন
                          _buildFieldLabel(strings.filterVehicleType),
                          const SizedBox(height: 6),
                          _buildDropdown(
                            hint: strings.selectVehicleType,
                            value: _selectedVehicle,
                            items: provider.vehicleTypes,
                            onChanged: (val) {
                              setState(() {
                                _selectedVehicle = val;
                                if (!_isTruck) {
                                  _isCoveredTruck = false;
                                  _vehicleLengthController.clear();
                                  _vehicleCapacityController.clear();
                                }
                                if (!_isBusOrMiniBus && !_isHelicopter) {
                                  _seatingCapacityController.clear();
                                }
                                if (!_isHelicopter) {
                                  _isAirAmbulance = false;
                                }
                                if (!_isMotorcycle) {
                                  _isSelfDriving = false;
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 14),

                          // 4. গাড়ির মডেল
                          _buildFieldLabel(strings.vehicleModel),
                          const SizedBox(height: 6),
                          _buildTextInput(
                            controller: _modelController,
                            hint: strings.vehicleModelPlaceholder,
                          ),
                          const SizedBox(height: 14),

                          // 5. গাড়ির নিবন্ধন নম্বর
                          _buildFieldLabel(strings.regNumber),
                          const SizedBox(height: 6),
                          _buildTextInput(
                            controller: _registrationNoController,
                            hint: strings.regNumberPlaceholder,
                          ),
                          const SizedBox(height: 14),

                          // Dynamic Vehicle-specific fields based on selection
                          // 1. Bus / Mini Bus
                          if (_isBusOrMiniBus) ...[
                            _buildFieldLabel(strings.seatingCapacityLabel),
                            const SizedBox(height: 6),
                            _buildTextInput(
                              controller: _seatingCapacityController,
                              hint: strings.seatingCapacityPlaceholder,
                            ),
                            const SizedBox(height: 14),
                          ],

                          // 2. Truck
                          if (_isTruck) ...[
                            _buildFieldLabel(strings.truckCoveredLabel),
                            const SizedBox(height: 6),
                            _buildCheckboxBox(
                              value: _isCoveredTruck,
                              text: strings.truckCoveredCheckbox,
                              onChanged: (val) =>
                                  setState(() => _isCoveredTruck = val),
                            ),
                            const SizedBox(height: 14),
                            _buildFieldLabel(strings.vehicleLengthLabel),
                            const SizedBox(height: 6),
                            _buildTextInput(
                              controller: _vehicleLengthController,
                              hint: strings.vehicleLengthPlaceholder,
                            ),
                            const SizedBox(height: 14),
                            _buildFieldLabel(strings.vehicleCapacityLabel),
                            const SizedBox(height: 6),
                            _buildTextInput(
                              controller: _vehicleCapacityController,
                              hint: strings.vehicleCapacityPlaceholder,
                            ),
                            const SizedBox(height: 14),
                          ],

                          // 3. Helicopter
                          if (_isHelicopter) ...[
                            _buildFieldLabel(strings.seatingCapacityLabel),
                            const SizedBox(height: 6),
                            _buildTextInput(
                              controller: _seatingCapacityController,
                              hint: strings.seatingCapacityPlaceholder,
                            ),
                            const SizedBox(height: 14),
                            _buildFieldLabel(strings.airAmbulanceLabel),
                            const SizedBox(height: 6),
                            _buildCheckboxBox(
                              value: _isAirAmbulance,
                              text: strings.airAmbulanceCheckbox,
                              onChanged: (val) =>
                                  setState(() => _isAirAmbulance = val),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // 4. Motorcycle
                          if (_isMotorcycle) ...[
                            _buildFieldLabel(strings.drivingOptionLabel),
                            const SizedBox(height: 6),
                            _buildCheckboxBox(
                              value: _isSelfDriving,
                              text: strings.drivingOptionCheckbox,
                              onChanged: (val) =>
                                  setState(() => _isSelfDriving = val),
                            ),
                            const SizedBox(height: 14),
                          ],

                          const SizedBox(height: 6),

                          // 6. অবস্থান (Location Section)
                          Text(
                            strings.locationSectionTitle,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Location Card with Border
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row 1: বিভাগ & জেলা
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildSubLabel(strings.filterDivision),
                                          const SizedBox(height: 4),
                                          _buildDropdown(
                                            hint: strings.selectDivision,
                                            value: _selectedDivision,
                                            items: provider.divisions,
                                            onChanged: (val) {
                                              setState(() {
                                                _selectedDivision = val;
                                                _selectedDistrict = null;
                                                _selectedUpazila = null;
                                                _selectedUnion = null;
                                                _availableUnions = [];
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildSubLabel(strings.filterDistrict),
                                          const SizedBox(height: 4),
                                          _buildDropdown(
                                            hint: strings.selectDistrict,
                                            value: _selectedDistrict,
                                            items: availableDistricts,
                                            isEnabled: _selectedDivision != null &&
                                                availableDistricts.isNotEmpty,
                                            onChanged: (val) {
                                              setState(() {
                                                _selectedDistrict = val;
                                                _selectedUpazila = null;
                                                _selectedUnion = null;
                                                _availableUnions = [];
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Row 2: উপজেলা & ইউনিয়ন/পৌরসভা (BD API dropdown)
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildSubLabel(strings.filterUpazila),
                                          const SizedBox(height: 4),
                                          _buildDropdown(
                                            hint: strings.selectUpazila,
                                            value: _selectedUpazila,
                                            items: availableUpazilas,
                                            isEnabled: _selectedDistrict != null &&
                                                availableUpazilas.isNotEmpty,
                                            onChanged: (val) {
                                              setState(() {
                                                _selectedUpazila = val;
                                                _selectedUnion = null;
                                                _availableUnions = [];
                                              });
                                              if (val != null) _fetchUnions(val);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                strings.filterUnion,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF374151),
                                                ),
                                              ),
                                              const Text(
                                                ' *',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          _buildDropdown(
                                            hint: _isLoadingUnions
                                                ? 'লোড হচ্ছে...'
                                                : strings.unionPlaceholder,
                                            value: _selectedUnion,
                                            items: _availableUnions,
                                            isEnabled: _selectedUpazila != null &&
                                                !_isLoadingUnions,
                                            isLoading: _isLoadingUnions,
                                            onChanged: (val) {
                                              setState(() => _selectedUnion = val);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Row 3: ওয়ার্ড
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSubLabel(strings.filterWard),
                                    const SizedBox(height: 4),
                                    _buildTextInput(
                                      controller: _wardController,
                                      hint: strings.wardPlaceholder,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // 7. পেমেন্ট তথ্য (Payment Information Section)
                          if (_selectedVehicle != null) ...[
                            const SizedBox(height: 16),
                            _buildPaymentSection(
                              context: context,
                              strings: strings,
                              settings: provider.globalSettings,
                              provider: provider,
                            ),
                          ],

                          if (_validationError != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              _validationError!,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Submit Action Button: 'নিবন্ধন করুন' / 'Register Now'
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryOrange,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _isSubmitting ? null : () => _submitForm(strings),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3.0,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      strings.registerNowBtn,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildSubLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      alignment: Alignment.centerLeft,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          fontSize: 13.5,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: const TextStyle(
            fontSize: 13,
            color: Color(0xFF94A3B8),
          ),
          border: InputBorder.none,
          errorStyle: const TextStyle(height: 0, fontSize: 0),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isEnabled = true,
    bool isLoading = false,
  }) {
    final active = isEnabled && items.isNotEmpty && !isLoading;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: active && items.contains(value) ? value : null,
          isDense: true,
          hint: Text(
            hint,
            style: TextStyle(
              fontSize: 12.5,
              color: active ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          isExpanded: true,
          icon: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryOrange,
                  ),
                )
              : Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: active ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
                  size: 18,
                ),
          items: active
              ? items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textDark,
                      ),
                    ),
                  );
                }).toList()
              : null,
          onChanged: active ? onChanged : null,
        ),
      ),
    );
  }

  Widget _buildCheckboxBox({
    required bool value,
    required String text,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                activeColor: AppColors.primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(color: Color(0xFF94A3B8), width: 1.5),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildPaymentSection({
    required BuildContext context,
    required AppStrings strings,
    required GlobalSettingsModel settings,
    required DriverProvider provider,
  }) {
    // Find VehicleTypeModel
    VehicleTypeModel? vType;
    if (_selectedVehicle != null && provider.vehicleTypeModels.isNotEmpty) {
      final matches = provider.vehicleTypeModels.where(
        (v) =>
            v.name.toLowerCase().trim() == _selectedVehicle!.toLowerCase().trim() ||
            AppStrings.areSameVehicleType(v.name, _selectedVehicle!),
      );
      if (matches.isNotEmpty) {
        vType = matches.first;
      }
    }

    final bool requiresPayment = (vType?.monthlyFee ?? 0) > 0;
    final num monthlyFee = vType?.monthlyFee ?? 0;
    final num vehicleDiscount = vType?.discountValue ?? 0;
    final String discountType = vType?.discountType ?? 'percentage';

    num durationDiscount = 0;
    if (_selectedDurationDays == 90) {
      durationDiscount = settings.discount3Months;
    } else if (_selectedDurationDays == 180) {
      durationDiscount = settings.discount6Months;
    } else if (_selectedDurationDays == 365) {
      durationDiscount = settings.discount1Year;
    }

    final int calculatedAmount = requiresPayment
        ? FirebaseService.calculateRenewalAmount(
            monthlyFee: monthlyFee,
            durationDays: _selectedDurationDays,
            vehicleDiscount: vehicleDiscount,
            discountType: discountType,
            durationDiscount: durationDiscount,
          )
        : 0;

    int getAmountFor(int days, num durDiscount) {
      if (!requiresPayment) return 0;
      return FirebaseService.calculateRenewalAmount(
        monthlyFee: monthlyFee,
        durationDays: days,
        vehicleDiscount: vehicleDiscount,
        discountType: discountType,
        durationDiscount: durDiscount,
      );
    }

    final fee1M = getAmountFor(30, 0);
    final fee3M = getAmountFor(90, settings.discount3Months);
    final fee6M = getAmountFor(180, settings.discount6Months);
    final fee1Y = getAmountFor(365, settings.discount1Year);

    if (!requiresPayment) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFBBF7D0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                strings.isBn
                    ? 'এই গাড়ির ধরন নিবন্ধনের জন্য কোনো ফি প্রযোজ্য নয় (সম্পূর্ণ ফ্রি লাইসেন্স)।'
                    : 'No registration fee required for this vehicle (Free License).',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF15803D),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final phoneNum = RegExp(r'01\d{9}').firstMatch(settings.paymentInstructions)?.group(0) ?? '01677234297';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            strings.isBn ? 'পেমেন্ট তথ্য (Payment Information)' : 'Payment Information',
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF92400E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            strings.isBn
                ? '${_selectedVehicle ?? ""} এর জন্য মাসিক ফি $monthlyFee টাকা।'
                : 'Monthly fee for ${_selectedVehicle ?? ""}: $monthlyFee Tk.',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB45309),
            ),
          ),
          const SizedBox(height: 12),

          // Duration & Amount Row
          Row(
            children: [
              // Duration Dropdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.isBn ? 'সাবস্ক্রিপশনের মেয়াদ' : 'Subscription Duration',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      alignment: Alignment.center,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedDurationDays,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w500,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 30,
                              child: Text(strings.isBn ? '১ মাস (৩০ দিন) - $fee1M ৳' : '1 Month (30 days) - $fee1M Tk'),
                            ),
                            DropdownMenuItem(
                              value: 90,
                              child: Text(strings.isBn ? '৩ মাস (৯০ দিন) - $fee3M ৳${settings.discount3Months > 0 ? " (${settings.discount3Months}% ছাড়)" : ""}' : '3 Months (90 days) - $fee3M Tk'),
                            ),
                            DropdownMenuItem(
                              value: 180,
                              child: Text(strings.isBn ? '৬ মাস (১৮০ দিন) - $fee6M ৳${settings.discount6Months > 0 ? " (${settings.discount6Months}% ছাড়)" : ""}' : '6 Months (180 days) - $fee6M Tk'),
                            ),
                            DropdownMenuItem(
                              value: 365,
                              child: Text(strings.isBn ? '১ বছর (৩৬৫ দিন) - $fee1Y ৳${settings.discount1Year > 0 ? " (${settings.discount1Year}% ছাড়)" : ""}' : '1 Year (365 days) - $fee1Y Tk'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedDurationDays = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Amount to Pay
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.isBn ? 'পরিশোধের পরিমাণ' : 'Amount to Pay',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$calculatedAmount টাকা',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Payment Mode: Automated vs Manual
          if (settings.automatedPayment) ...[
            // --- bKash Automatic Payment Card ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: BkashColors.lightBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: BkashColors.borderPink),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const BkashLogoBadge(size: 26, isWhite: false),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          strings.bkashDriverBadge,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Recipient Merchant Account
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet_outlined,
                            size: 16, color: BkashColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${strings.bkashMerchantAccount}: 01677234297',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(
                                const ClipboardData(text: '01677234297'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '01677234297 - ${strings.copiedToClipboard}'),
                                backgroundColor: BkashColors.primary,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: BkashColors.lightBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.copy_rounded,
                                size: 13, color: BkashColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Payment bKash Number (Auto-filled & Editable)
                  Text(
                    strings.bkashAccountLabel,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.phone_android_rounded,
                          size: 18,
                          color: BkashColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _paymentPhoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              hintText: _phoneController.text.isNotEmpty
                                  ? _phoneController.text
                                  : '01XXXXXXXXX',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    strings.savedBkashNotice,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF64748B),
                    ),
                  ),

                  if (_transactionIdController.text.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF16A34A), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '✓ বিকাশ পেমেন্ট সম্পন্ন! TrxID: ${_transactionIdController.text}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Primary Pay with bKash Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: BkashColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  final phone = _paymentPhoneController.text.trim().isNotEmpty
                      ? _paymentPhoneController.text.trim()
                      : _phoneController.text.trim();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => BkashPaymentSheet(
                      amount: calculatedAmount,
                      defaultPhone: phone,
                      driverId: 'new_registration',
                      driverName: _nameController.text.trim(),
                      driverPhone: _phoneController.text.trim(),
                      onPaymentComplete: (trxId, bkashNum) {
                        setState(() {
                          _transactionIdController.text = trxId;
                          _paymentPhoneController.text = bkashNum;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('বিকাশ পেমেন্ট সফল হয়েছে! TrxID: $trxId'),
                            backgroundColor: const Color(0xFF16A34A),
                          ),
                        );
                      },
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CustomPaint(
                      size: Size(18, 18),
                      painter: BkashBirdPainter(color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _transactionIdController.text.isNotEmpty
                          ? 'পেমেন্ট সম্পন্ন (পুনরায় পে করতে ক্লিক করুন)'
                          : strings.payWithBkashBtn(calculatedAmount),
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Manual Payment Instructions & TrxID field (matching Image 2)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settings.paymentInstructions,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF78350F),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: phoneNum));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$phoneNum - ${strings.copiedToClipboard}'),
                          backgroundColor: const Color(0xFFD97706),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.copy_rounded, size: 14, color: Color(0xFFD97706)),
                        const SizedBox(width: 4),
                        Text(
                          '$phoneNum (${strings.isBn ? 'নম্বর কপি করুন' : 'Copy Number'})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // TrxID Input Field
            Text(
              '${strings.isBn ? "ট্রানজেকশন আইডি (Transaction ID)" : "Transaction ID"} *',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: _transactionIdController,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'e.g. 8N7A6B5C4D',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
