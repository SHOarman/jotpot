import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../core/models/driver_model.dart';
import '../../core/providers/driver_provider.dart';
import '../../utils/app_theme.dart';

class RegisterDriverScreen extends StatefulWidget {
  const RegisterDriverScreen({super.key});

  @override
  State<RegisterDriverScreen> createState() => _RegisterDriverScreenState();
}

class _RegisterDriverScreenState extends State<RegisterDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _detailsController = TextEditingController();

  String _selectedVehicle = 'Car';
  String _selectedDivision = 'ঢাকা';
  String _selectedDistrict = 'ঢাকা';
  String _selectedUpazila = 'ধামরাই';
  String _selectedUnion = 'ধামরাই পৌরসভা';
  String _selectedWard = 'ওয়ার্ড ১';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newDriver = DriverModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        vehicleType: _selectedVehicle,
        division: _selectedDivision,
        district: _selectedDistrict,
        upazila: _selectedUpazila,
        union: _selectedUnion,
        ward: _selectedWard,
        address: _addressController.text.trim(),
        details: _detailsController.text.trim(),
      );

      final provider = Provider.of<DriverProvider>(context, listen: false);
      provider.addDriver(newDriver);

      Get.snackbar(
        'সফল হয়েছে!',
        'আপনার গাড়ির তথ্য ডিরেক্টরিতে যোগ করা হয়েছে।',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );

      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DriverProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ড্রাইভার হিসেবে নিবন্ধন',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'আপনার গাড়ির বিবরণ দিন',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'আপনার নাম / প্রতিষ্ঠানের নাম',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'নাম লিখুন' : null,
              ),
              const SizedBox(height: 14),

              // Phone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'মোবাইল নম্বর',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'নম্বর লিখুন' : null,
              ),
              const SizedBox(height: 14),

              // Vehicle Dropdown
              DropdownButtonFormField<String>(
                value: _selectedVehicle,
                decoration: const InputDecoration(
                  labelText: 'গাড়ির ধরন',
                  border: OutlineInputBorder(),
                ),
                items: provider.vehicleTypes
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedVehicle = val);
                },
              ),
              const SizedBox(height: 14),

              // Division & District
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDivision,
                      decoration: const InputDecoration(
                        labelText: 'বিভাগ',
                        border: OutlineInputBorder(),
                      ),
                      items: provider.divisions
                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDivision = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDistrict,
                      decoration: const InputDecoration(
                        labelText: 'জেলা',
                        border: OutlineInputBorder(),
                      ),
                      items: provider.districts
                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDistrict = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Upazila & Union
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedUpazila,
                      decoration: const InputDecoration(
                        labelText: 'উপজেলা',
                        border: OutlineInputBorder(),
                      ),
                      items: provider.upazilas
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedUpazila = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnion,
                      decoration: const InputDecoration(
                        labelText: 'ইউনিয়ন/পৌরসভা',
                        border: OutlineInputBorder(),
                      ),
                      items: provider.unions
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedUnion = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Ward & Address
              DropdownButtonFormField<String>(
                value: _selectedWard,
                decoration: const InputDecoration(
                  labelText: 'ওয়ার্ড',
                  border: OutlineInputBorder(),
                ),
                items: provider.wards
                    .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedWard = val);
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'সম্পূর্ণ ঠিকানা (যেমন: abc, ধামরাই, ঢাকা)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'ঠিকানা লিখুন' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _detailsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'অতিরিক্ত বিবরণ (ঐচ্ছিক)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submitForm,
                  child: const Text(
                    'নিবন্ধন সম্পন্ন করুন',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
