import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/services/hive_service.dart';
import '../../policy/policy_content.dart';
import '../../policy/widgets/policy_dialog.dart';

/// Authentic bKash Brand Colors
class BkashColors {
  static const Color primary = Color(0xFFE2136E); // Signature bKash Magenta
  static const Color primaryDark = Color(0xFFC2185B);
  static const Color lightBg = Color(0xFFFDF2F7);
  static const Color borderPink = Color(0xFFF8BBD0);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color btnGray = Color(0xFFEEEEEE);
  static const Color btnTextDark = Color(0xFF475569);
}

/// Official Origami Bird Painter for bKash Logo
class BkashBirdPainter extends CustomPainter {
  final Color color;
  const BkashBirdPainter({this.color = const Color(0xFFE2136E)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;

    // Head triangle
    final pathHead = Path()
      ..moveTo(w * 0.45, h * 0.05)
      ..lineTo(w * 0.85, h * 0.22)
      ..lineTo(w * 0.58, h * 0.38)
      ..close();
    canvas.drawPath(pathHead, paint);

    // Beak
    final pathBeak = Path()
      ..moveTo(w * 0.85, h * 0.22)
      ..lineTo(w * 0.98, h * 0.25)
      ..lineTo(w * 0.78, h * 0.32)
      ..close();
    canvas.drawPath(pathBeak, paint);

    // Main body triangle
    final pathBody = Path()
      ..moveTo(w * 0.58, h * 0.38)
      ..lineTo(w * 0.72, h * 0.78)
      ..lineTo(w * 0.20, h * 0.60)
      ..close();
    canvas.drawPath(pathBody, paint);

    // Tail / Wing top
    final pathWing = Path()
      ..moveTo(w * 0.20, h * 0.60)
      ..lineTo(w * 0.02, h * 0.28)
      ..lineTo(w * 0.45, h * 0.42)
      ..close();
    canvas.drawPath(pathWing, paint);

    // Bottom Tail
    final pathTail = Path()
      ..moveTo(w * 0.20, h * 0.60)
      ..lineTo(w * 0.12, h * 0.88)
      ..lineTo(w * 0.42, h * 0.72)
      ..close();
    canvas.drawPath(pathTail, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BkashOfficialLogo extends StatelessWidget {
  final double size;

  const BkashOfficialLogo({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'বিকাশ',
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w900,
            fontFamily: 'sans-serif',
            color: BkashColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 4),
        CustomPaint(
          size: Size(size * 1.05, size * 1.05),
          painter: const BkashBirdPainter(color: BkashColors.primary),
        ),
      ],
    );
  }
}

/// Backward compatibility badge
class BkashLogoBadge extends StatelessWidget {
  final double size;
  final bool isWhite;

  const BkashLogoBadge({super.key, this.size = 28, this.isWhite = false});

  @override
  Widget build(BuildContext context) {
    return BkashOfficialLogo(size: size);
  }
}

/// bKash Payment Dialog matching official Tokenized Checkout design
class BkashPaymentSheet extends StatefulWidget {
  final int amount;
  final String defaultPhone;
  final String driverId;
  final String driverName;
  final String driverPhone;
  final String merchantNumber;
  final bool isSavedNumber;
  final Function(String transactionId, String bkashNumber) onPaymentComplete;

  const BkashPaymentSheet({
    super.key,
    required this.amount,
    required this.defaultPhone,
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.onPaymentComplete,
    this.merchantNumber = '01677234297',
    this.isSavedNumber = false,
  });

  @override
  State<BkashPaymentSheet> createState() => _BkashPaymentSheetState();
}

class _BkashPaymentSheetState extends State<BkashPaymentSheet> {
  // Steps: 0 = Account Number, 1 = Verification Code (OTP), 2 = PIN
  int _currentStep = 0;

  late final TextEditingController _accountNoController;
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  String? _errorMessage;
  bool _isProcessing = false;
  late final String _invoiceNumber;

  @override
  void initState() {
    super.initState();
    // Pre-fill with user's number or remembered bKash number
    _accountNoController = TextEditingController(text: widget.defaultPhone);

    // Generate authentic looking invoice ID like in official bKash checkout
    final randomHex = List.generate(
      16,
      (_) => Random().nextInt(16).toRadixString(16),
    ).join();
    _invoiceNumber =
        '${widget.driverId.padRight(8, '0').substring(0, 8)}$randomHex';
  }

  @override
  void dispose() {
    _accountNoController.dispose();
    _otpController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  // --- Step 1 Confirm: Validate phone and proceed to OTP ---
  void _onStep1Confirm() {
    final phone = _accountNoController.text.trim();
    if (phone.length < 11) {
      setState(() => _errorMessage = 'সঠিক ১১ ডিজিটের মোবাইল নম্বর দিন');
      return;
    }
    setState(() {
      _errorMessage = null;
      _currentStep = 1;
    });
  }

  // --- Step 2 Confirm: Validate OTP and proceed to PIN ---
  void _onStep2Confirm() {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      setState(() => _errorMessage = '৬-সংখ্যার ভেরিফিকেশন কোড লিখুন');
      return;
    }
    setState(() {
      _errorMessage = null;
      _currentStep = 2;
    });
  }

  // --- Step 3 Confirm: Complete Demo Payment ---
  Future<void> _onStep3Confirm() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      setState(() => _errorMessage = 'বিকাশ পিন নম্বর লিখুন');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    // Realistic simulation delay
    await Future.delayed(const Duration(milliseconds: 1000));

    final bkashNum = _accountNoController.text.trim();
    final randomPart = Random().nextInt(9000000) + 1000000;
    final generatedTrx = 'BKS${randomPart}A';

    // Save this bKash number in Hive for future renewals
    await HiveService.saveLastBkashNumber(
      driverPhone: widget.driverPhone,
      bkashNumber: bkashNum,
      driverId: widget.driverId,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    Navigator.of(context).pop();
    widget.onPaymentComplete(generatedTrx, bkashNum);
  }

  void _onConfirm() {
    if (_currentStep == 0) {
      _onStep1Confirm();
    } else if (_currentStep == 1) {
      _onStep2Confirm();
    } else if (_currentStep == 2) {
      _onStep3Confirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Top White Header with Centered bKash Official Logo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                color: Colors.white,
                child: const Center(child: BkashOfficialLogo(size: 26)),
              ),

              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

              // 2. Merchant Info Section
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Merchant Avatar & Details
                    Row(
                      children: [
                        // Circle Avatar (like Programming Hero in reference)
                        Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF0284C7), Color(0xFFE2136E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(
                            Icons.directions_car_filled_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Jotpot',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: BkashColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Inv No: $_invoiceNumber',
                              style: const TextStyle(
                                fontSize: 11,
                                color: BkashColors.textMuted,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Amount on Right
                    Text(
                      '৳${widget.amount}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: BkashColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Main Magenta Container (Exact visual match)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                color: BkashColors.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Dynamic Title based on Step
                    Text(
                      _currentStep == 0
                          ? 'Your bKash Account Number'
                          : _currentStep == 1
                          ? 'bKash Verification Code'
                          : 'Enter PIN',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Centered Input Box
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildInputField(),
                    ),

                    if (_currentStep == 1) ...[
                      const SizedBox(height: 10),
                      // Demo OTP Helper Chip
                      InkWell(
                        onTap: () {
                          setState(() {
                            _otpController.text = '123456';
                            _errorMessage = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '⚡ অটো-কোড বসান: 123456',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.yellowAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Footer Link / Terms
                    GestureDetector(
                      onTap: () => PolicyDialog.show(
                        context,
                        PolicyType.termsAndConditions,
                      ),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white,
                            fontFamily: 'sans-serif',
                          ),
                          children: [
                            TextSpan(text: 'Confirm and proceed, '),
                            TextSpan(
                              text: 'terms & conditions',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Action Buttons (Cancel / Confirm)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: BkashColors.btnGray,
                                foregroundColor: BkashColors.btnTextDark,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () {
                                if (_currentStep > 0) {
                                  setState(() {
                                    _currentStep--;
                                    _errorMessage = null;
                                  });
                                } else {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Text(
                                _currentStep > 0 ? 'Back' : 'Cancel',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // Confirm Button
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: BkashColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: _isProcessing ? null : _onConfirm,
                              child: _isProcessing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3.0,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Confirm',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 16247 Helpline with phone icon (as shown in image)
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone, size: 13, color: BkashColors.primary),
                        SizedBox(width: 4),
                        Text(
                          '16247',
                          style: TextStyle(
                            color: BkashColors.primary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Input Field based on current step ---
  Widget _buildInputField() {
    if (_currentStep == 0) {
      // Step 1: Phone number field
      return TextField(
        controller: _accountNoController,
        keyboardType: TextInputType.phone,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: BkashColors.textDark,
          letterSpacing: 0.5,
        ),
        cursorColor: BkashColors.primary,
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: 'e.g 01XXXXXXXXX',
          hintStyle: TextStyle(
            fontSize: 15,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.normal,
          ),
        ),
        onSubmitted: (_) => _onConfirm(),
      );
    } else if (_currentStep == 1) {
      // Step 2: Verification Code field
      return TextField(
        controller: _otpController,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 6,
          color: BkashColors.textDark,
        ),
        cursorColor: BkashColors.primary,
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: 'e.g 6 digits',
          hintStyle: TextStyle(
            fontSize: 14,
            letterSpacing: 0,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.normal,
          ),
        ),
        onSubmitted: (_) => _onConfirm(),
      );
    } else {
      // Step 3: PIN field
      return TextField(
        controller: _pinController,
        obscureText: true,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 4,
          color: BkashColors.textDark,
        ),
        cursorColor: BkashColors.primary,
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: 'Enter 5 digit PIN',
          hintStyle: TextStyle(
            fontSize: 14,
            letterSpacing: 0,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.normal,
          ),
        ),
        onSubmitted: (_) => _onConfirm(),
      );
    }
  }
}
