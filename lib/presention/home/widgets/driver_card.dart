import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/driver_model.dart';
import '../../../core/services/firebase_service.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/app_theme.dart';

class DriverCard extends StatelessWidget {
  final DriverModel driver;

  const DriverCard({super.key, required this.driver});

  Future<void> _makeCall(BuildContext context) async {
    // 1. Track call in Firestore Analytics
    FirebaseService.trackCallClick(
      driver.id,
      driver.name,
      driver.vehicleType,
    );

    // 2. Direct call link using tel: scheme (no message, directly open dialer)
    final cleanPhone = driver.phone.trim().replaceAll(RegExp(r'\s+'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanPhone,
    );

    try {
      if (kIsWeb) {
        await launchUrl(launchUri, webOnlyWindowName: '_self');
      } else {
        final launched = await launchUrl(
          launchUri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          await launchUrl(launchUri);
        }
      }
    } catch (_) {
      try {
        await launchUrl(launchUri);
      } catch (_) {}
    }
  }

  /// Show a full detail dialog when the card is tapped.
  void _showDetailDialog(BuildContext context) {
    final strings = AppStrings.of(context);
    final locUpazila = strings.translateUpazila(driver.upazila);
    final locDistrict = strings.translateDistrict(driver.district);
    final displayDetails = driver.getLocalizedDetails(isBn: strings.isBn);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: Name + Close ──────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.renewBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              strings.vehicleCategoryName(driver.vehicleType),
                              style: const TextStyle(
                                color: AppColors.renewText,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close_rounded,
                          color: Color(0xFF94A3B8), size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 20),

                // ── Vehicle Details ───────────────────────────────────────
                if (displayDetails.isNotEmpty) ...[
                  _detailRow(
                    icon: Icons.directions_car_rounded,
                    color: const Color(0xFF3B82F6),
                    label: strings.isBn ? 'গাড়ির বিবরণ' : 'Vehicle Details',
                    value: displayDetails,
                  ),
                  const SizedBox(height: 14),
                ],

                // ── Phone ─────────────────────────────────────────────────
                _detailRow(
                  icon: Icons.phone_rounded,
                  color: const Color(0xFF10B981),
                  label: strings.mobileNumber,
                  value: driver.phone,
                ),
                const SizedBox(height: 14),

                // ── Location ──────────────────────────────────────────────
                _detailRow(
                  icon: Icons.location_on_rounded,
                  color: AppColors.locationRed,
                  label: strings.isBn ? 'অবস্থান' : 'Location',
                  value: _buildLocationText(
                    strings,
                    locUpazila,
                    locDistrict,
                  ),
                ),

                // ── Union & Ward ──────────────────────────────────────────
                if (driver.union.isNotEmpty || driver.ward.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _detailRow(
                    icon: Icons.map_rounded,
                    color: const Color(0xFF8B5CF6),
                    label: strings.isBn ? 'ইউনিয়ন / ওয়ার্ড' : 'Union / Ward',
                    value: [
                      if (driver.union.isNotEmpty) driver.union,
                      if (driver.ward.isNotEmpty) driver.ward,
                    ].join(' • '),
                  ),
                ],

                // ── Seat Count ────────────────────────────────────────────
                if (driver.seatCount != null && driver.seatCount! > 0) ...[
                  const SizedBox(height: 14),
                  _detailRow(
                    icon: Icons.event_seat_rounded,
                    color: AppColors.infoTeal,
                    label: strings.isBn ? 'আসন সংখ্যা' : 'Seats',
                    value: '${driver.seatCount}',
                  ),
                ] else if (driver.seatingCapacity.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _detailRow(
                    icon: Icons.event_seat_rounded,
                    color: AppColors.infoTeal,
                    label: strings.isBn ? 'আসন সংখ্যা' : 'Seats',
                    value: driver.seatingCapacity,
                  ),
                ],

                // ── Truck Features ───────────────────────────────────────
                if (driver.isCovered) ...[
                  const SizedBox(height: 14),
                  _detailRow(
                    icon: Icons.local_shipping_rounded,
                    color: const Color(0xFF6366F1),
                    label: strings.isBn ? 'গাড়ির কভার' : 'Covered Status',
                    value: strings.isBn ? 'কাভার্ড ট্রাক (Covered Truck)' : 'Covered Truck',
                  ),
                ],
                if (driver.vehicleLength.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _detailRow(
                    icon: Icons.straighten_rounded,
                    color: const Color(0xFF0284C7),
                    label: strings.isBn ? 'গাড়ির দৈর্ঘ্য' : 'Vehicle Length',
                    value: driver.vehicleLength,
                  ),
                ],
                if (driver.vehicleCapacity.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _detailRow(
                    icon: Icons.fitness_center_rounded,
                    color: const Color(0xFF0D9488),
                    label: strings.isBn ? 'ধারন ক্ষমতা' : 'Capacity',
                    value: driver.vehicleCapacity,
                  ),
                ],

                // ── Air Ambulance Feature ────────────────────────────────
                if (driver.isAirAmbulance) ...[
                  const SizedBox(height: 14),
                  _detailRow(
                    icon: Icons.medical_services_rounded,
                    color: const Color(0xFFDC2626),
                    label: strings.isBn ? 'এয়ার অ্যাম্বুলেন্স' : 'Air Ambulance',
                    value: strings.isBn ? 'হ্যাঁ, এয়ার অ্যাম্বুলেন্স' : 'Yes, Air Ambulance',
                  ),
                ],

                // ── Self Driving / Rent Feature ──────────────────────────
                if (driver.isSelfDriving) ...[
                  const SizedBox(height: 14),
                  _detailRow(
                    icon: Icons.key_rounded,
                    color: const Color(0xFFEA580C),
                    label: strings.isBn ? 'ড্রাইভিং অপশন' : 'Driving Option',
                    value: strings.isBn
                        ? 'সেলফ ড্রাইভিং / ড্রাইভার ছাড়া রেন্ট'
                        : 'Self Driving / Rent without driver',
                  ),
                ],

                // ── Notes / Address (read-only text area) ─────────────────
                if (driver.address.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    strings.isBn ? 'ঠিকানা / নোট' : 'Address / Notes',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: SelectableText(
                      driver.address,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF334155),
                        height: 1.6,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // ── Call Button ───────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _makeCall(context);
                    },
                    icon: const Icon(Icons.phone_rounded,
                        color: Colors.white, size: 20),
                    label: Text(
                      strings.callNow,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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

  /// Build a single info row with icon + label + value.
  Widget _detailRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardChip({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.28),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _buildLocationText(
      AppStrings strings, String locUpazila, String locDistrict) {
    final parts = <String>[];
    if (locUpazila.isNotEmpty) parts.add(locUpazila);
    if (locDistrict.isNotEmpty) parts.add(locDistrict);
    final divTrans = strings.translateDivision(driver.division);
    if (divTrans.isNotEmpty) parts.add(divTrans);
    return parts.isNotEmpty ? parts.join(', ') : driver.address;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    final locUpazila = strings.translateUpazila(driver.upazila);
    final locDistrict = strings.translateDistrict(driver.district);
    final fallbackLoc = (locUpazila.isNotEmpty && locDistrict.isNotEmpty)
        ? '$locUpazila, $locDistrict'
        : (locDistrict.isNotEmpty ? locDistrict : locUpazila);

    final locationText =
        driver.address.isNotEmpty ? driver.address : fallbackLoc;

    final displayDetails = driver.getLocalizedDetails(isBn: strings.isBn);

    // Vehicle Specific Features (Seat count, Truck specs, Air Ambulance, Self Driving)
    final featureChips = <Widget>[];

    // A. Seat Count / Seating Capacity
    final seatVal = (driver.seatCount != null && driver.seatCount! > 0)
        ? '${driver.seatCount}'
        : driver.seatingCapacity.trim();
    if (seatVal.isNotEmpty) {
      featureChips.add(
        _buildCardChip(
          icon: Icons.event_seat_rounded,
          color: AppColors.infoTeal,
          text: '${strings.seatingCountPrefix}$seatVal',
        ),
      );
    }

    // B. Truck Covered Status
    if (driver.isCovered) {
      featureChips.add(
        _buildCardChip(
          icon: Icons.local_shipping_rounded,
          color: const Color(0xFF6366F1),
          text: strings.isBn ? 'কাভার্ড ট্রাক' : 'Covered Truck',
        ),
      );
    }

    // C. Truck Vehicle Length
    if (driver.vehicleLength.trim().isNotEmpty) {
      featureChips.add(
        _buildCardChip(
          icon: Icons.straighten_rounded,
          color: const Color(0xFF0284C7),
          text: '${strings.isBn ? "দৈর্ঘ্য: " : "Length: "}${driver.vehicleLength.trim()}',
        ),
      );
    }

    // D. Truck Vehicle Capacity
    if (driver.vehicleCapacity.trim().isNotEmpty) {
      featureChips.add(
        _buildCardChip(
          icon: Icons.fitness_center_rounded,
          color: const Color(0xFF0D9488),
          text: '${strings.isBn ? "ধারণ ক্ষমতা: " : "Capacity: "}${driver.vehicleCapacity.trim()}',
        ),
      );
    }

    // E. Helicopter Air Ambulance
    if (driver.isAirAmbulance) {
      featureChips.add(
        _buildCardChip(
          icon: Icons.medical_services_rounded,
          color: const Color(0xFFDC2626),
          text: strings.isBn ? 'এয়ার অ্যাম্বুলেন্স' : 'Air Ambulance',
        ),
      );
    }

    // F. Motorcycle Self Driving
    if (driver.isSelfDriving) {
      featureChips.add(
        _buildCardChip(
          icon: Icons.key_rounded,
          color: const Color(0xFFEA580C),
          text: strings.isBn
              ? 'সেলফ ড্রাইভিং / রেন্ট'
              : 'Self Driving / Rent',
        ),
      );
    }
    return GestureDetector(
      onTap: () => _showDetailDialog(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFFAFBFC)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Row: Driver/Vehicle Name & Vehicle Type Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    driver.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Vehicle Type Pill Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.renewBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    strings.vehicleCategoryName(driver.vehicleType),
                    style: const TextStyle(
                      color: AppColors.renewText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // 2. Subtitle / Details (e.g. Model: 2011 | Registration: 121416)
            if (displayDetails.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                displayDetails,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // 3. Location Row with Red Pin Icon
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppColors.locationRed,
                  size: 17,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    locationText,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textBody,
                    ),
                  ),
                ),
                // Tap hint
                const Icon(Icons.open_in_new_rounded,
                    size: 14, color: Color(0xFFCBD5E1)),
              ],
            ),

            // 4. Vehicle Specific Features Badges (if any)
            if (featureChips.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: featureChips,
              ),
            ],

            const SizedBox(height: 18),
            // 5. Full-Width Vibrant Orange Call Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _makeCall(context),
                icon: const Icon(
                  Icons.phone_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                label: Text(
                  strings.callNow,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
