import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/models/driver_model.dart';
import '../../../core/models/global_settings_model.dart';
import '../../../core/models/vehicle_type_model.dart';
import '../../../core/providers/driver_provider.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/hive_service.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/app_theme.dart';
import 'bkash_payment_sheet.dart';

class RenewLicenseDialog extends StatefulWidget {
  const RenewLicenseDialog({super.key});

  @override
  State<RenewLicenseDialog> createState() => _RenewLicenseDialogState();
}

class _RenewLicenseDialogState extends State<RenewLicenseDialog> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _trxController = TextEditingController();
  final TextEditingController _bkashController = TextEditingController();

  DriverModel? _foundDriver;
  bool _isSearching = false;
  String? _searchError;

  int _selectedDurationDays = 30;
  final bool _autoPay = false;
  bool _isSubmitting = false;
  bool _isSuccess = false;
  String? _submitError;

  bool _isBkashSaved = false;
  bool _showManualTrx = false;
  String _lastSubmittedTrx = '';
  String _lastSubmittedBkash = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _trxController.dispose();
    _bkashController.dispose();
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

          // Check if driver or device has remembered bKash number
          final savedBkash = driver.lastBkashNumber.trim().isNotEmpty
              ? driver.lastBkashNumber.trim()
              : HiveService.getLastBkashNumber(
                  driverPhone: driver.phone,
                  driverId: driver.id,
                );

          if (savedBkash != null && savedBkash.trim().isNotEmpty) {
            _bkashController.text = savedBkash.trim();
            _isBkashSaved = true;
          } else {
            _bkashController.text = driver.phone;
            _isBkashSaved = false;
          }
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
    required AppStrings strings,
    String? providedTrx,
    String? providedBkashNumber,
  }) async {
    if (_foundDriver == null) return;

    final bkashNum = (providedBkashNumber != null &&
            providedBkashNumber.trim().isNotEmpty)
        ? providedBkashNumber.trim()
        : (_bkashController.text.trim().isNotEmpty
            ? _bkashController.text.trim()
            : _foundDriver!.phone);

    String transactionId;
    if (!requiresPayment) {
      transactionId = 'FREE_RENEWAL';
    } else if (providedTrx != null && providedTrx.trim().isNotEmpty) {
      transactionId = providedTrx.trim();
    } else if (_trxController.text.trim().isNotEmpty) {
      transactionId = _trxController.text.trim();
    } else {
      if (_trxController.text.trim().isEmpty) {
        setState(() {
          _submitError = strings.trxRequiredError;
        });
        return;
      }
      transactionId = _trxController.text.trim();
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      // Save bKash number in Hive for instant memory on next renewals
      await HiveService.saveLastBkashNumber(
        driverPhone: _foundDriver!.phone,
        bkashNumber: bkashNum,
        driverId: _foundDriver!.id,
      );

      await FirebaseService.submitRenewalToAdmin(
        driverId: _foundDriver!.id,
        driverName: _foundDriver!.name,
        driverPhone: _foundDriver!.phone,
        transactionId: transactionId,
        durationDays: _selectedDurationDays,
        amount: amount,
        bkashNumber: bkashNum,
        autoPay: _autoPay,
      );

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _isSuccess = true;
        _lastSubmittedTrx = transactionId;
        _lastSubmittedBkash = bkashNum;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitError = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  void _openBkashPaymentModal({
    required int calculatedAmount,
    required AppStrings strings,
  }) {
    if (_foundDriver == null) return;
    final currentPhone = _bkashController.text.trim().isNotEmpty
        ? _bkashController.text.trim()
        : _foundDriver!.phone;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => BkashPaymentSheet(
        amount: calculatedAmount,
        defaultPhone: currentPhone,
        driverId: _foundDriver!.id,
        driverName: _foundDriver!.name,
        driverPhone: _foundDriver!.phone,
        merchantNumber: '01677234297',
        isSavedNumber: _isBkashSaved,
        onPaymentComplete: (trxId, bkashNum) {
          setState(() {
            _bkashController.text = bkashNum;
            _trxController.text = trxId;
            _isBkashSaved = true;
          });
          _submitRenewal(
            amount: calculatedAmount,
            requiresPayment: true,
            strings: strings,
            providedTrx: trxId,
            providedBkashNumber: bkashNum,
          );
        },
      ),
    );
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
                      strokeWidth: 3.0,
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
    final num monthlyFee = vType?.monthlyFee ?? 0;
    final num vehicleDiscount = vType?.discountValue ?? 0;
    final String discountType = vType?.discountType ?? 'percentage';

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

    final vehicleModelText = (driver.vehicleModel.isNotEmpty)
        ? driver.vehicleModel
        : (strings.isBn ? 'গাড়ি' : 'Vehicle');
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
                    '${strings.registrationLabel}: ${driver.vehicleRegNumber}',
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
                              child: Text(
                                strings.isBn
                                    ? '১ মাস (৩০ দিন) - $fee1M ৳'
                                    : '1 Month (30 days) - $fee1M Tk',
                              ),
                            ),
                            DropdownMenuItem(
                              value: 90,
                              child: Text(
                                strings.isBn
                                    ? '৩ মাস (৯০ দিন) - $fee3M ৳${settings.discount3Months > 0 ? " (${settings.discount3Months}% ছাড়)" : ""}'
                                    : '3 Months (90 days) - $fee3M Tk${settings.discount3Months > 0 ? " (${settings.discount3Months}% off)" : ""}',
                              ),
                            ),
                            DropdownMenuItem(
                              value: 180,
                              child: Text(
                                strings.isBn
                                    ? '৬ মাস (১৮০ দিন) - $fee6M ৳${settings.discount6Months > 0 ? " (${settings.discount6Months}% ছাড়)" : ""}'
                                    : '6 Months (180 days) - $fee6M Tk${settings.discount6Months > 0 ? " (${settings.discount6Months}% off)" : ""}',
                              ),
                            ),
                            DropdownMenuItem(
                              value: 365,
                              child: Text(
                                strings.isBn
                                    ? '১ বছর (৩৬৫ দিন) - $fee1Y ৳${settings.discount1Year > 0 ? " (${settings.discount1Year}% ছাড়)" : ""}'
                                    : '1 Year (365 days) - $fee1Y Tk${settings.discount1Year > 0 ? " (${settings.discount1Year}% off)" : ""}',
                              ),
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

          // Check if Automated Payment Gateway is ON or OFF in Admin Dashboard
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
                          color: _isBkashSaved
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _isBkashSaved
                              ? '✓ ${strings.bkashSavedBadge}'
                              : strings.bkashDriverBadge,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: _isBkashSaved
                                ? const Color(0xFF15803D)
                                : const Color(0xFF1D4ED8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Recipient Account
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
                            controller: _bkashController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              hintText: '01XXXXXXXXX',
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
                onPressed: _isSubmitting
                    ? null
                    : () => _openBkashPaymentModal(
                          calculatedAmount: calculatedAmount,
                          strings: strings,
                        ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 3.0,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CustomPaint(
                            size: Size(18, 18),
                            painter: BkashBirdPainter(color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            strings.payWithBkashBtn(calculatedAmount),
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 10),

            // Toggle for manual Trx ID entry
            Center(
              child: InkWell(
                onTap: () => setState(() => _showManualTrx = !_showManualTrx),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _showManualTrx
                            ? 'ম্যানুয়াল ট্রানজেকশন আইডি লুকান'
                            : 'অথবা আগে টাকা পাঠালে TrxID লিখুন',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _showManualTrx
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (_showManualTrx) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          strings.transactionIdLabel,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const Text(
                          ' *',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        controller: _trxController,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: strings.transactionIdPlaceholder,
                          hintStyle: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF94A3B8),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: BkashColors.primary),
                          foregroundColor: BkashColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isSubmitting
                            ? null
                            : () => _submitRenewal(
                                  amount: calculatedAmount,
                                  requiresPayment: true,
                                  strings: strings,
                                ),
                        child: Text(
                          strings.submitRenewalRequest,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            // --- MANUAL PAYMENT SYSTEM (When Automated Gateway is OFF in Admin Dashboard) ---
            Container(
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
                  Row(
                    children: [
                      const Icon(Icons.payment_rounded,
                          size: 18, color: Color(0xFFD97706)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          strings.isBn ? 'পেমেন্ট নির্দেশাবলী' : 'Payment Instructions',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    settings.paymentInstructions,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF78350F),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Copy account button
                  InkWell(
                    onTap: () {
                      final pNum = RegExp(r'01\d{9}').firstMatch(settings.paymentInstructions)?.group(0) ?? '01677234297';
                      Clipboard.setData(ClipboardData(text: pNum));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$pNum - ${strings.copiedToClipboard}'),
                          backgroundColor: const Color(0xFFD97706),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.copy_rounded, size: 13, color: Color(0xFFD97706)),
                          const SizedBox(width: 6),
                          Text(
                            strings.isBn ? 'অ্যাকাউন্ট নম্বর কপি করুন' : 'Copy Account Number',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // TrxID Input Field (Required)
            Row(
              children: [
                Text(
                  strings.transactionIdLabel,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
                controller: _trxController,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
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
            const SizedBox(height: 14),

            // Submit Renewal Request Button
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
                    : () {
                        if (_trxController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(strings.isBn
                                  ? 'অনুগ্রহ করে ট্রানজেকশন আইডি (TrxID) লিখুন'
                                  : 'Please enter transaction ID (TrxID)'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }
                        _submitRenewal(
                          amount: calculatedAmount,
                          requiresPayment: true,
                          strings: strings,
                        );
                      },
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
                        strings.isBn
                            ? 'পেমেন্ট তথ্য সাবমিট ও নবায়ন করুন'
                            : 'Submit Payment & Renew',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ],
        if (_submitError != null) ...[
          const SizedBox(height: 12),
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
        ],
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
        const SizedBox(height: 14),

        // Receipt Summary Card
        if (_lastSubmittedBkash.isNotEmpty || _lastSubmittedTrx.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_lastSubmittedBkash.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'বিকাশ নম্বর:',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            _lastSubmittedBkash,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'সংরক্ষিত',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                if (_lastSubmittedTrx.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TrxID:',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        _lastSubmittedTrx,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: BkashColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'মেয়াদ বৃদ্ধি:',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      '$_selectedDurationDays দিন',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

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
