import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/driver_model.dart';
import '../../../core/models/global_settings_model.dart';
import '../../../core/models/vehicle_type_model.dart';
import '../../../core/providers/driver_provider.dart';
import '../../../core/services/firebase_service.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/app_theme.dart';

class RenewLicenseDialog extends StatefulWidget {
  const RenewLicenseDialog({super.key});

  @override
  State<RenewLicenseDialog> createState() => _RenewLicenseDialogState();
}

class _RenewLicenseDialogState extends State<RenewLicenseDialog> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _trxController = TextEditingController();

  DriverModel? _foundDriver;
  bool _isSearching = false;
  String? _searchError;

  int _selectedDurationDays = 30;
  bool _autoPay = false;
  bool _isSubmitting = false;
  bool _isSuccess = false;
  String? _submitError;

  @override
  void dispose() {
    _phoneController.dispose();
    _trxController.dispose();
    super.dispose();
  }

  Future<void> _searchDriver(AppStrings strings) async {
    final query = _phoneController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchError = strings.phoneLabel;
        _foundDriver = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
      _foundDriver = null;
    });

    try {
      // 1. Search directly in Firestore drivers collection
      DriverModel? driver = await FirebaseService.searchDriverByPhone(query);

      // 2. Fallback search in currently loaded provider drivers
      if (driver == null && mounted) {
        final provider = Provider.of<DriverProvider>(context, listen: false);
        final matched =
            provider.drivers.where((d) => d.phone.contains(query)).toList();
        if (matched.isNotEmpty) {
          driver = matched.first;
        }
      }

      if (!mounted) return;

      setState(() {
        _isSearching = false;
        if (driver != null) {
          _foundDriver = driver;
          _searchError = null;
        } else {
          _searchError = strings.driverNotFound;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _searchError = strings.searchErrorGeneric;
      });
    }
  }

  Future<void> _submitRenewal({
    required int amount,
    required bool requiresPayment,
    required bool automatedPayment,
    required AppStrings strings,
  }) async {
    if (_foundDriver == null) return;

    if (requiresPayment &&
        !automatedPayment &&
        _trxController.text.trim().isEmpty) {
      setState(() {
        _submitError = strings.trxRequiredError;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      String transactionId;
      if (!requiresPayment) {
        transactionId = 'FREE_RENEWAL';
      } else if (automatedPayment) {
        if (_autoPay) {
          transactionId = 'AUTO-${DateTime.now().millisecondsSinceEpoch}';
        } else if (_trxController.text.trim().isNotEmpty) {
          transactionId = _trxController.text.trim();
        } else {
          transactionId = 'BKASH-PAY-${DateTime.now().millisecondsSinceEpoch}';
        }
      } else {
        transactionId = _trxController.text.trim();
      }

      await FirebaseService.submitRenewalToAdmin(
        driverId: _foundDriver!.id,
        driverName: _foundDriver!.name,
        driverPhone: _foundDriver!.phone,
        transactionId: transactionId,
        durationDays: _selectedDurationDays,
        amount: amount,
        autoPay: _autoPay,
      );

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _isSuccess = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitError = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DriverProvider>(context);
    final settings = provider.globalSettings;
    final strings = AppStrings.of(context);

    // Find vehicle type info
    VehicleTypeModel? vType;
    if (_foundDriver != null && provider.vehicleTypeModels.isNotEmpty) {
      final matches = provider.vehicleTypeModels.where(
        (v) =>
            v.name.toLowerCase().trim() ==
                _foundDriver!.vehicleType.toLowerCase().trim() ||
            AppStrings.areSameVehicleType(v.name, _foundDriver!.vehicleType),
      );
      if (matches.isNotEmpty) {
        vType = matches.first;
      }
    }

    final bool requiresPayment = (vType?.monthlyFee ?? 300) > 0;
    final num monthlyFee = vType?.monthlyFee ?? 300;
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

    final int calculatedAmount = FirebaseService.calculateRenewalAmount(
      monthlyFee: monthlyFee,
      durationDays: _selectedDurationDays,
      vehicleDiscount: vehicleDiscount,
      discountType: discountType,
      durationDiscount: durationDiscount,
    );

    final double rawBase = (monthlyFee / 30) * _selectedDurationDays;
    final bool hasDiscount = rawBase.round() > calculatedAmount;
    final int savedAmount = (rawBase - calculatedAmount).round();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Title & Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          strings.renewDialogTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                  const SizedBox(height: 12),

                  // Display Step View
                  if (_isSuccess)
                    _buildSuccessView(strings)
                  else if (_foundDriver == null)
                    _buildPhoneSearchView(strings)
                  else
                    _buildRenewalFormView(
                      settings: settings,
                      vType: vType,
                      requiresPayment: requiresPayment,
                      calculatedAmount: calculatedAmount,
                      rawBase: rawBase,
                      hasDiscount: hasDiscount,
                      savedAmount: savedAmount,
                      strings: strings,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- 1. Step 1: Phone Search View ---
  Widget _buildPhoneSearchView(AppStrings strings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.renewDialogSubtitle,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          strings.phoneLabel,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _searchError != null
                  ? Colors.redAccent
                  : const Color(0xFFE2E8F0),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: strings.phonePlaceholder,
              hintStyle: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF94A3B8),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: (_) => _searchDriver(strings),
          ),
        ),
        if (_searchError != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.redAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _searchError!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
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
            onPressed: _isSearching ? null : () => _searchDriver(strings),
            child: _isSearching
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    strings.searchDriverBtn,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // --- 2. Step 2: Driver Details & Dynamic Renewal Form ---
  Widget _buildRenewalFormView({
    required GlobalSettingsModel settings,
    required VehicleTypeModel? vType,
    required bool requiresPayment,
    required int calculatedAmount,
    required double rawBase,
    required bool hasDiscount,
    required int savedAmount,
    required AppStrings strings,
  }) {
    final driver = _foundDriver!;
    final bool automatedPayment = settings.automatedPayment;
    final String gatewayName = settings.paymentGatewayName.isNotEmpty
        ? settings.paymentGatewayName
        : 'bkash';

    // Expiry calculation
    int remainingDays = 0;
    bool isExpired = true;
    bool isUnlimited = !requiresPayment;

    if (driver.expiryDate != null) {
      final now = DateTime.now();
      if (driver.expiryDate!.isAfter(now)) {
        remainingDays = driver.expiryDate!.difference(now).inDays + 1;
        isExpired = false;
      }
      if (driver.expiryDate!.year > 2090) {
        isUnlimited = true;
      }
    }

    final vehicleModelText =
        (driver.vehicleModel.isNotEmpty) ? driver.vehicleModel : 'Vehicle';
    final vehicleCategoryTranslated =
        strings.vehicleCategoryName(driver.vehicleType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Driver Details Card (matching screenshot 2 & 4)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    driver.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _foundDriver = null;
                        _searchError = null;
                      });
                    },
                    child: Text(
                      strings.changeDriver,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                driver.phone,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$vehicleModelText ($vehicleCategoryTranslated)',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF475569),
                ),
              ),
              if (driver.vehicleRegNumber.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    'Reg: ${driver.vehicleRegNumber}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              // Expiry Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isUnlimited
                      ? const Color(0xFFEFF6FF)
                      : isExpired
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isUnlimited
                      ? strings.unlimitedBadge
                      : isExpired
                          ? strings.expiredBadge
                          : strings.validDaysBadge(remainingDays),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isUnlimited
                        ? const Color(0xFF1D4ED8)
                        : isExpired
                            ? const Color(0xFFB91C1C)
                            : const Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        if (isUnlimited) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Text(
              strings.unlimitedVehicleNotice,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E40AF),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ] else ...[
          // Payment Instructions Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFEDD5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.paymentInstructionsTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9A3412),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  settings.paymentInstructions.isNotEmpty
                      ? settings.paymentInstructions
                      : 'Please send the payment via bkash/nagad to jotpot personal account: 01677234297',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF9A3412),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Duration & Amount Row
          Row(
            children: [
              // Duration Dropdown
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.durationLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      alignment: Alignment.center,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: _selectedDurationDays,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF64748B),
                            size: 20,
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w500,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 30,
                              child: Text(strings.duration1Month),
                            ),
                            DropdownMenuItem(
                              value: 90,
                              child: Text(strings.duration3Months),
                            ),
                            DropdownMenuItem(
                              value: 180,
                              child: Text(strings.duration6Months),
                            ),
                            DropdownMenuItem(
                              value: 365,
                              child: Text(strings.duration1Year),
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
              const SizedBox(width: 12),

              // Calculated Amount Field
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.amountLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Text(
                            strings.amountWithCurrency(calculatedAmount),
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  strings.saveTag(savedAmount),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF15803D),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Automated Payment Option Checkbox
          if (automatedPayment) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _autoPay,
                    activeColor: AppColors.primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (val) {
                      setState(() => _autoPay = val ?? false);
                    },
                  ),
                  Expanded(
                    child: Text(
                      strings.autoPayCheckbox,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Transaction ID input for manual payment
          if (!automatedPayment || !_autoPay) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      strings.transactionIdLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    if (automatedPayment)
                      Text(
                        strings.manualPaymentSub,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      )
                    else
                      const Text(
                        ' *',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: _trxController,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textDark,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: strings.transactionIdPlaceholder,
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ],

        if (_submitError != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Text(
              _submitError!,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF991B1B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Action Submit Button
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
            onPressed: _isSubmitting
                ? null
                : () => _submitRenewal(
                      amount: calculatedAmount,
                      requiresPayment: requiresPayment,
                      automatedPayment: automatedPayment,
                      strings: strings,
                    ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    isUnlimited
                        ? strings.completeRenewal
                        : automatedPayment
                            ? strings.payWithGateway(gatewayName)
                            : strings.submitRenewalRequest,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // --- 3. Step 3: Success Confirmation View ---
  Widget _buildSuccessView(AppStrings strings) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Color(0xFF16A34A),
            size: 34,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          strings.renewSuccessTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          strings.renewSuccessSubtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
              foregroundColor: const Color(0xFF334155),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              strings.closeButton,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
