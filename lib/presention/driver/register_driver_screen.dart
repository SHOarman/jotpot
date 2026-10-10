import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../core/models/driver_model.dart';
import '../../core/providers/driver_provider.dart';
import '../../utils/app_theme.dart';
import '../home/widgets/home_chat_fab.dart';

class RegisterDriverScreen extends StatefulWidget {
  const RegisterDriverScreen({super.key});

  @override
  State<RegisterDriverScreen> createState() => _RegisterDriverScreenState();
}

class _RegisterDriverScreenState extends State<RegisterDriverScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _modelController = TextEditingController();
  final _registrationNoController = TextEditingController();
  final _unionController = TextEditingController();
  final _wardController = TextEditingController();

  // Selection states
  String? _selectedVehicle;
  String? _selectedDivision;
  String? _selectedDistrict;
  String? _selectedUpazila;
  bool _autoPay = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _modelController.dispose();
    _registrationNoController.dispose();
    _unionController.dispose();
    _wardController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedVehicle == null) {
        _showErrorSnackBar('অনুগ্রহ করে গাড়ির ধরন নির্বাচন করুন');
        return;
      }
      if (_selectedDivision == null) {
        _showErrorSnackBar('অনুগ্রহ করে বিভাগ নির্বাচন করুন');
        return;
      }

      final newDriver = DriverModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        vehicleType: _selectedVehicle!,
        division: _selectedDivision ?? 'ঢাকা',
        district: _selectedDistrict ?? _selectedDivision ?? 'ঢাকা',
        upazila: _selectedUpazila ?? '',
        union: _unionController.text.trim(),
        ward: _wardController.text.trim(),
        address: [
          if (_unionController.text.trim().isNotEmpty) _unionController.text.trim(),
          if (_selectedUpazila != null && _selectedUpazila!.isNotEmpty) _selectedUpazila!,
          if (_selectedDistrict != null && _selectedDistrict!.isNotEmpty) _selectedDistrict!,
        ].join(', '),
        details: [
          if (_modelController.text.trim().isNotEmpty)
            'মডেল: ${_modelController.text.trim()}',
          if (_registrationNoController.text.trim().isNotEmpty)
            'রেজিস্ট্রেশন: ${_registrationNoController.text.trim()}',
        ].join(' | '),
      );

      final provider = Provider.of<DriverProvider>(context, listen: false);
      provider.addDriver(newDriver);

      Get.snackbar(
        'সফল হয়েছে!',
        'ড্রাইভার হিসেবে সফলভাবে নিবন্ধন করা হয়েছে।',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF059669),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );

      Get.back();
    }
  }

  void _showErrorSnackBar(String message) {
    Get.snackbar(
      'তথ্য অসম্পূর্ণ',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DriverProvider>(context);

    // Cascading district options based on selected division
    final List<String> availableDistricts = _selectedDivision != null
        ? (DriverProvider.geoHierarchy[_selectedDivision]?.keys.toList() ??
            <String>[])
        : <String>[];

    // Cascading upazila options based on selected district
    final List<String> availableUpazilas =
        (_selectedDivision != null && _selectedDistrict != null)
            ? (DriverProvider.geoHierarchy[_selectedDivision]?[_selectedDistrict] ??
                <String>[])
            : <String>[];


    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildCustomAppBar(provider),
      floatingActionButton: const HomeChatFab(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Hero Title & Subtitle
                  const Text(
                    'ড্রাইভার নিবন্ধন',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'আমাদের ডিরেক্টরিতে যোগ দিন এবং আরও কাস্টমার পান।',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Main Form Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. পুরো নাম
                        _buildFieldLabel('পুরো নাম'),
                        const SizedBox(height: 6),
                        _buildTextInput(
                          controller: _nameController,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'পুরো নাম লিখুন' : null,
                        ),
                        const SizedBox(height: 16),

                        // 2. ফোন নম্বর
                        _buildFieldLabel('ফোন নম্বর'),
                        const SizedBox(height: 6),
                        _buildTextInput(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'ফোন নম্বর লিখুন' : null,
                        ),
                        const SizedBox(height: 16),

                        // 3. গাড়ির ধরন (Dropdown)
                        _buildFieldLabel('গাড়ির ধরন'),
                        const SizedBox(height: 6),
                        _buildDropdown(
                          hint: 'গাড়ির ধরন নির্বাচন করুন',
                          value: _selectedVehicle,
                          items: provider.vehicleTypes,
                          onChanged: (val) {
                            setState(() => _selectedVehicle = val);
                          },
                        ),
                        const SizedBox(height: 16),

                        // 4. গাড়ির মডেল
                        _buildFieldLabel('গাড়ির মডেল'),
                        const SizedBox(height: 6),
                        _buildTextInput(
                          controller: _modelController,
                        ),
                        const SizedBox(height: 16),

                        // 5. গাড়ির নিবন্ধন নম্বর
                        _buildFieldLabel('গাড়ির নিবন্ধন নম্বর'),
                        const SizedBox(height: 6),
                        _buildTextInput(
                          controller: _registrationNoController,
                          hint: 'e.g. Dhaka Metro-Ga 12-3456',
                        ),
                        const SizedBox(height: 16),

                        // 6. Auto Pay Checkbox Card
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() => _autoPay = !_autoPay);
                            },
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Checkbox(
                                    value: _autoPay,
                                    activeColor: AppColors.primaryOrange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    side: const BorderSide(
                                      color: Color(0xFF94A3B8),
                                      width: 1.5,
                                    ),
                                    onChanged: (val) {
                                      setState(() => _autoPay = val ?? false);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Auto Pay via Automated Payment Gateway (অটো পে)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 7. অবস্থান (Location Section)
                        const Text(
                          'অবস্থান',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Location Card with Border
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Row 1: বিভাগ & জেলা
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildSubLabel('বিভাগ'),
                                        const SizedBox(height: 6),
                                        _buildDropdown(
                                          hint: 'বিভাগ নির্বাচন করুন',
                                          value: _selectedDivision,
                                          items: provider.divisions,
                                          onChanged: (val) {
                                            setState(() {
                                              _selectedDivision = val;
                                              _selectedDistrict = null;
                                              _selectedUpazila = null;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildSubLabel('জেলা'),
                                        const SizedBox(height: 6),
                                        _buildDropdown(
                                          hint: 'জেলা নির্বাচন করুন',
                                          value: _selectedDistrict,
                                          items: availableDistricts,
                                          isEnabled:
                                              _selectedDivision != null &&
                                                  availableDistricts.isNotEmpty,
                                          onChanged: (val) {
                                            setState(() {
                                              _selectedDistrict = val;
                                              _selectedUpazila = null;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Row 2: উপজেলা & ইউনিয়ন/পৌরসভা *
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildSubLabel('উপজেলা'),
                                        const SizedBox(height: 6),
                                        _buildDropdown(
                                          hint: 'উপজেলা নির্বাচন করুন',
                                          value: _selectedUpazila,
                                          items: availableUpazilas,
                                          isEnabled:
                                              _selectedDistrict != null &&
                                                  availableUpazilas.isNotEmpty,
                                          onChanged: (val) {
                                            setState(() {
                                              _selectedUpazila = val;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: const [
                                            Text(
                                              'ইউনিয়ন/পৌরসভা',
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF374151),
                                              ),
                                            ),
                                            Text(
                                              ' *',
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        _buildTextInput(
                                          controller: _unionController,
                                          hint: 'ইউনিয়ন/পৌরসভা নির্বাচন করুন',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Row 3: ওয়ার্ড
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSubLabel('ওয়ার্ড'),
                                  const SizedBox(height: 6),
                                  _buildTextInput(
                                    controller: _wardController,
                                    hint: 'ওয়ার্ড নির্বাচন করুন',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit Action Button: 'নিবন্ধন করুন'
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _submitForm,
                      child: const Text(
                        'নিবন্ধন করুন',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Label Widget
  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
      ),
    );
  }

  // Sub Label inside location card
  Widget _buildSubLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
    );
  }

  // Text Input Box matching screenshot
  Widget _buildTextInput({
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 46,
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

  // Dropdown Box matching screenshot
  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isEnabled = true,
  }) {
    final active = isEnabled && items.isNotEmpty;

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
              fontSize: 13,
              color: active ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: active ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
            size: 20,
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

  // Custom AppBar matching screenshot 2
  PreferredSizeWidget _buildCustomAppBar(DriverProvider provider) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: AppColors.borderLight,
          height: 1,
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: AppColors.textDark,
        ),
        onPressed: () => Get.back(),
      ),
      titleSpacing: 0,
      title: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'JOT',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
                letterSpacing: 0.5,
              ),
            ),
            TextSpan(
              text: 'POT',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryOrange,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Center(
          child: Text(
            'ড্রাইভার হিসেবে নিবন্ধন করুন',
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Language Selector [🌐 EN]
        InkWell(
          onTap: () => provider.toggleLanguage(),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.language,
                  size: 14,
                  color: AppColors.textDark,
                ),
                const SizedBox(width: 4),
                Text(
                  provider.isBengali ? 'EN' : 'বাংলা',
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Shield Icon
        const Icon(
          Icons.shield_outlined,
          size: 18,
          color: Color(0xFF64748B),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
