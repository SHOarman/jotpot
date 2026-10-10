import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/driver_model.dart';
import '../../../core/providers/driver_provider.dart';
import '../../../utils/app_theme.dart';

class RegisterDriverDialog extends StatefulWidget {
  const RegisterDriverDialog({super.key});

  @override
  State<RegisterDriverDialog> createState() => _RegisterDriverDialogState();
}

class _RegisterDriverDialogState extends State<RegisterDriverDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
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
  String? _validationError;

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
    setState(() => _validationError = null);

    if (_formKey.currentState!.validate()) {
      if (_selectedVehicle == null) {
        setState(() => _validationError = 'অনুগ্রহ করে গাড়ির ধরন নির্বাচন করুন');
        return;
      }
      if (_selectedDivision == null) {
        setState(() => _validationError = 'অনুগ্রহ করে বিভাগ নির্বাচন করুন');
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
          if (_unionController.text.trim().isNotEmpty)
            _unionController.text.trim(),
          if (_selectedUpazila != null && _selectedUpazila!.isNotEmpty)
            _selectedUpazila!,
          if (_selectedDistrict != null && _selectedDistrict!.isNotEmpty)
            _selectedDistrict!,
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

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ড্রাইভার হিসেবে সফলভাবে নিবন্ধন করা হয়েছে!'),
          backgroundColor: Color(0xFF059669),
          duration: Duration(seconds: 3),
        ),
      );
    }
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

    return Dialog(
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
                      children: const [
                        Text(
                          'ড্রাইভার নিবন্ধন',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'আমাদের ডিরেক্টরিতে যোগ দিন এবং আরও কাস্টমার পান।',
                          style: TextStyle(
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
                  child: Form(
                    key: _formKey,
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
                        const SizedBox(height: 14),

                        // 2. ফোন নম্বর
                        _buildFieldLabel('ফোন নম্বর'),
                        const SizedBox(height: 6),
                        _buildTextInput(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'ফোন নম্বর লিখুন' : null,
                        ),
                        const SizedBox(height: 14),

                        // 3. গাড়ির ধরন
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
                        const SizedBox(height: 14),

                        // 4. গাড়ির মডেল
                        _buildFieldLabel('গাড়ির মডেল'),
                        const SizedBox(height: 6),
                        _buildTextInput(
                          controller: _modelController,
                        ),
                        const SizedBox(height: 14),

                        // 5. গাড়ির নিবন্ধন নম্বর
                        _buildFieldLabel('গাড়ির নিবন্ধন নম্বর'),
                        const SizedBox(height: 6),
                        _buildTextInput(
                          controller: _registrationNoController,
                          hint: 'e.g. Dhaka Metro-Ga 12-3456',
                        ),
                        const SizedBox(height: 14),

                        // 6. Auto Pay Checkbox Card
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() => _autoPay = !_autoPay);
                            },
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
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
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Auto Pay via Automated Payment Gateway (অটো পে)',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 7. অবস্থান (Location Section)
                        const Text(
                          'অবস্থান',
                          style: TextStyle(
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
                                        _buildSubLabel('বিভাগ'),
                                        const SizedBox(height: 4),
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
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildSubLabel('জেলা'),
                                        const SizedBox(height: 4),
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
                              const SizedBox(height: 10),

                              // Row 2: উপজেলা & ইউনিয়ন/পৌরসভা *
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildSubLabel('উপজেলা'),
                                        const SizedBox(height: 4),
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
                                  const SizedBox(width: 10),
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
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF374151),
                                              ),
                                            ),
                                            Text(
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
                                        _buildTextInput(
                                          controller: _unionController,
                                          hint: 'ইউনিয়ন/পৌরসভা লিখুন',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Row 3: ওয়ার্ড
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSubLabel('ওয়ার্ড'),
                                  const SizedBox(height: 4),
                                  _buildTextInput(
                                    controller: _wardController,
                                    hint: 'ওয়ার্ড লিখুন',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

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

                        // Submit Action Button: 'নিবন্ধন করুন'
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
                            onPressed: _submitForm,
                            child: const Text(
                              'নিবন্ধন করুন',
                              style: TextStyle(
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
  }) {
    final active = isEnabled && items.isNotEmpty;

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
          icon: Icon(
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
}
