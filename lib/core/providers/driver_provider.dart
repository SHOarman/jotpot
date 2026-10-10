import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../services/hive_service.dart';

class DriverProvider extends ChangeNotifier {
  List<DriverModel> _drivers = [];
  bool _isLoading = false;

  // Search & Filters
  String _searchQuery = '';
  String? _selectedVehicleType;
  String? _selectedDivision;
  String? _selectedDistrict;
  String? _selectedUpazila;
  String? _selectedUnion;
  String? _selectedWard;

  // Modes & Language
  bool _isBengali = true;
  bool _isUnityMode = false; // Home Mode vs Unity Mode

  // Notice Text
  String _noticeText = 'যেকোনো প্রয়োজন বা সহায়তার জন্য কল করুন: 01677234252';

  DriverProvider() {
    loadDrivers();
  }

  // Getters
  List<DriverModel> get drivers => _drivers;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedVehicleType => _selectedVehicleType;
  String? get selectedDivision => _selectedDivision;
  String? get selectedDistrict => _selectedDistrict;
  String? get selectedUpazila => _selectedUpazila;
  String? get selectedUnion => _selectedUnion;
  String? get selectedWard => _selectedWard;
  bool get isBengali => _isBengali;
  bool get isUnityMode => _isUnityMode;
  String get noticeText => _noticeText;

  // Bangladesh Division -> District -> Upazila Geographic Mapping
  static const Map<String, Map<String, List<String>>> geoHierarchy = {
    'বরিশাল': {
      'ভোলা': [
        'Burhanuddin',
        'ভোলা সদর',
        'দৌলতখান',
        'লালমোহন',
        'চরফ্যাশন',
        'তজুমদ্দিন',
        'মনপুরা',
      ],
      'বরিশাল': [
        'বরিশাল সদর',
        'বাকেরগঞ্জ',
        'বাবুগঞ্জ',
        'উজিরপুর',
        'বানারীপাড়া',
        'গৌরনদী',
        'মুলাদী',
        'মেহেন্দিগঞ্জ',
        'হিজলা',
      ],
      'পটুয়াখালী': [
        'পটুয়াখালী সদর',
        'বাউফল',
        'গলাচিপা',
        'দশমিনা',
        'কলাপাড়া',
        'মির্জাগঞ্জ',
        'দুমকি',
        'রাঙ্গাবালী',
      ],
      'পিরোজপুর': [
        'পিরোজপুর সদর',
        'ভান্ডারিয়া',
        'মঠবাড়িয়া',
        'নাজিরপুর',
        'কাউখালী',
        'নেছারাবাদ',
        'ইন্দুরকানী',
      ],
      'বরগুনা': [
        'বরগুনা সদর',
        'আমতলী',
        'পাথরঘাটা',
        'বেতাগী',
        'বামনা',
        'তালতলী',
      ],
      'ঝালকাঠি': [
        'ঝালকাঠি সদর',
        'নলছিটি',
        'রাজাপুর',
        'কাঠালিয়া',
      ],
    },
    'ঢাকা': {
      'ঢাকা': [
        'ধামরাই',
        'সাভার',
        'মিরপুর',
        'উত্তরা',
        'গুলশান',
        'কেরানীগঞ্জ',
        'দোহার',
        'নবাবগঞ্জ',
      ],
      'গাজীপুর': [
        'টঙ্গী',
        'গাজীপুর সদর',
        'কালিয়াকৈর',
        'শ্রীপুর',
        'কাপাসিয়া',
      ],
      'নারায়ণগঞ্জ': [
        'নারায়ণগঞ্জ সদর',
        'রূপগঞ্জ',
        'সোনারগাঁও',
        'আড়াইহাজার',
        'বন্দর',
      ],
      'টাঙ্গাইল': [
        'টাঙ্গাইল সদর',
        'মির্জাপুর',
        'মধুপুর',
        'ঘাটাইল',
        'সখিপুর',
        'গোপালপুর',
        'নাগরপুর',
      ],
      'নরসিংদী': [
        'নরসিংদী সদর',
        'পলাশ',
        'বেলাব',
        'শিবপুর',
        'রায়পুরা',
        'মনোহরদী',
      ],
      'মুন্সিগঞ্জ': [
        'মুন্সিগঞ্জ সদর',
        'সিরাজদিখান',
        'শ্রীনগর',
        'টঙ্গীবাড়ী',
        'গজারিয়া',
        'লৌহজং',
      ],
      'মানিকগঞ্জ': [
        'মানিকগঞ্জ সদর',
        'সিংগাইর',
        'সাটুরিয়া',
        'শিবালয়',
        'ঘিওর',
        'দৌলতপুর',
        'হরিরামপুর',
      ],
      'কিশোরগঞ্জ': [
        'কিশোরগঞ্জ সদর',
        'ভৈরব',
        'বাজিতপুর',
        'হোসেনপুর',
        'কটিয়াদী',
        'করিমগঞ্জ',
      ],
    },
    'চট্টগ্রাম': {
      'চট্টগ্রাম': [
        'পতেঙ্গা',
        'পাঁচলাইশ',
        'পাহাড়তলী',
        'কোতোয়ালী',
        'সীতাকুণ্ড',
        'মিরসরাই',
        'হাটহাজারী',
        'রাউজান',
      ],
      'কক্সবাজার': [
        'কক্সবাজার সদর',
        'টেকনাফ',
        'উখিয়া',
        'রামু',
        'মহেশখালী',
        'চকরিয়া',
      ],
      'কুমিল্লা': [
        'কুমিল্লা সদর',
        'লাকসাম',
        'দাউদকান্দি',
        'চৌদ্দগ্রাম',
        'দেবীদ্বার',
        'মুরাদনগর',
      ],
      'ফেনী': [
        'ফেনী সদর',
        'দাগনভূঞা',
        'সোনাগাজী',
        'ছাগলনাইয়া',
      ],
      'নোয়াখালী': [
        'নোয়াখালী সদর',
        'বেগমগঞ্জ',
        'চাটখিল',
        'কোম্পানীগঞ্জ',
      ],
      'চাঁদপুর': [
        'চাঁদপুর সদর',
        'হাজীগঞ্জ',
        'মতলব',
        'শাহরাস্তি',
      ],
    },
    'রাজশাহী': {
      'রাজশাহী': ['রাজশাহী সদর', 'বাঘা', 'চারঘাট', 'পুঠিয়া', 'গোদাগাড়ী'],
      'বগুড়া': ['বগুড়া সদর', 'শেরপুর', 'শিবগঞ্জ', 'কাহালু', 'ধুনট'],
      'পাবনা': ['পাবনা সদর', 'ঈশ্বরদী', 'সাঁথিয়া', 'সুজানগর', 'বেড়া'],
      'সিরাজগঞ্জ': ['সিরাজগঞ্জ সদর', 'শাহজাদপুর', 'উল্লাপাড়া', 'বেলকুচি'],
      'নাটোর': ['নাটোর সদর', 'সিংড়া', 'বড়াইগ্রাম', 'গুরুদাসপুর'],
    },
    'খুলনা': {
      'খুলনা': ['খুলনা সদর', 'দৌলতপুর', 'খালিশপুর', 'ডুমুরিয়া', 'বটিয়াঘাটা'],
      'যশোর': ['যশোর সদর', 'ঝিকরগাছা', 'অভয়নগর', 'কেশবপুর'],
      'কুষ্টিয়া': ['কুষ্টিয়া সদর', 'কুমারখালী', 'ভেড়ামারা', 'মিরপুর'],
      'সাতক্ষীরা': ['সাতক্ষীরা সদর', 'কালীগঞ্জ', 'শ্যামনগর'],
    },
    'সিলেট': {
      'সিলেট': ['সিলেট সদর', 'বিয়ানীবাজার', 'গোলাপগঞ্জ', 'জৈন্তাপুর', 'বিশ্বনাথ'],
      'মৌলভীবাজার': ['মৌলভীবাজার সদর', 'শ্রীমঙ্গল', 'কমলগঞ্জ', 'কুলাউড়া'],
      'হবিগঞ্জ': ['হবিগঞ্জ সদর', 'মাধবপুর', 'চুনারুঘাট', 'নবীগঞ্জ'],
      'সুনামগঞ্জ': ['সুনামগঞ্জ সদর', 'ছাতক', 'জগন্নাথপুর', 'তাহিরপুর'],
    },
    'রংপুর': {
      'রংপুর': ['রংপুর সদর', 'বদরগঞ্জ', 'পীরগঞ্জ', 'মিঠাপুকুর'],
      'দিনাজপুর': ['দিনাজপুর সদর', 'বীরগঞ্জ', 'বিরামপুর', 'পার্বতীপুর'],
      'কুড়িগ্রাম': ['কুড়িগ্রাম সদর', 'নাগেশ্বরী', 'উলিপুর'],
    },
    'ময়মনসিংহ': {
      'ময়মনসিংহ': ['ময়মনসিংহ সদর', 'ত্রিশাল', 'ভালুকা', 'মুক্তাগাছা', 'গফরগাঁও'],
      'জামালপুর': ['জামালপুর সদর', 'মেলান্দহ', 'মাদারগঞ্জ', 'সরিষাবাড়ী'],
      'শেরপুর': ['শেরপুর সদর', 'নকলা', 'নালিতাবাড়ী', 'শ্রীবরদী'],
      'নেত্রকোণা': ['নেত্রকোণা সদর', 'কেন্দুয়া', 'পূর্বধলা', 'দুর্গাপুর'],
    },
  };

  // Preset Filter Options
  List<String> get vehicleTypes => [
        'Bus',
        'Car',
        'Microbus',
        'CNG',
        'Truck',
        'Ambulance',
        'Bike',
        'Pickup',
      ];

  // All divisions
  List<String> get divisions => geoHierarchy.keys.toList();

  // Cascading districts: Only shown if division is selected
  List<String> get districts {
    if (_selectedDivision == null) return [];
    return geoHierarchy[_selectedDivision]?.keys.toList() ?? [];
  }

  // Cascading upazilas: Only shown if district is selected
  List<String> get upazilas {
    if (_selectedDivision == null || _selectedDistrict == null) return [];
    return geoHierarchy[_selectedDivision]?[_selectedDistrict] ?? [];
  }

  // Predefined lists for registration screen dropdowns
  List<String> get unions => [
        'ধামরাই পৌরসভা',
        'টঙ্গী পৌরসভা',
        'সাভার পৌরসভা',
        'বাঘিল ইউনিয়ন',
        'পৌরসভা/ইউনিয়ন ১',
        'পৌরসভা/ইউনিয়ন ২',
      ];

  List<String> get wards => [
        'ওয়ার্ড ১',
        'ওয়ার্ড ২',
        'ওয়ার্ড ৩',
        'ওয়ার্ড ৪',
        'ওয়ার্ড ৫',
        'ওয়ার্ড ৬',
        'ওয়ার্ড ৭',
        'ওয়ার্ড ৮',
        'ওয়ার্ড ৯',
      ];

  /// Filtered drivers getter
  List<DriverModel> get filteredDrivers {
    return _drivers.where((driver) {
      final matchesSearch = _searchQuery.isEmpty ||
          driver.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          driver.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          driver.upazila.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          driver.union.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          driver.ward.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesVehicle = _selectedVehicleType == null ||
          driver.vehicleType == _selectedVehicleType;

      final matchesDivision =
          _selectedDivision == null || driver.division == _selectedDivision;

      final matchesDistrict =
          _selectedDistrict == null || driver.district == _selectedDistrict;

      final matchesUpazila =
          _selectedUpazila == null || driver.upazila == _selectedUpazila;

      final matchesUnion = _selectedUnion == null ||
          _selectedUnion!.trim().isEmpty ||
          driver.union.toLowerCase().contains(_selectedUnion!.trim().toLowerCase()) ||
          driver.address.toLowerCase().contains(_selectedUnion!.trim().toLowerCase());

      final matchesWard = _selectedWard == null ||
          _selectedWard!.trim().isEmpty ||
          driver.ward.toLowerCase().contains(_selectedWard!.trim().toLowerCase()) ||
          driver.address.toLowerCase().contains(_selectedWard!.trim().toLowerCase());

      return matchesSearch &&
          matchesVehicle &&
          matchesDivision &&
          matchesDistrict &&
          matchesUpazila &&
          matchesUnion &&
          matchesWard;
    }).toList();
  }

  /// Load drivers from Hive
  Future<void> loadDrivers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _drivers = HiveService.getAllDrivers();
    } catch (e) {
      debugPrint('Error loading drivers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add new driver
  Future<void> addDriver(DriverModel driver) async {
    await HiveService.addDriver(driver);
    await loadDrivers();
  }

  /// Delete driver
  Future<void> deleteDriver(String id) async {
    await HiveService.deleteDriver(id);
    await loadDrivers();
  }

  // Setters for filters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setVehicleType(String? val) {
    _selectedVehicleType = val;
    notifyListeners();
  }

  void setDivision(String? val) {
    _selectedDivision = val;
    _selectedDistrict = null; // Reset child district
    _selectedUpazila = null;  // Reset child upazila
    notifyListeners();
  }

  void setDistrict(String? val) {
    _selectedDistrict = val;
    _selectedUpazila = null;  // Reset child upazila
    notifyListeners();
  }

  void setUpazila(String? val) {
    _selectedUpazila = val;
    notifyListeners();
  }

  void setUnion(String? val) {
    _selectedUnion = val;
    notifyListeners();
  }

  void setWard(String? val) {
    _selectedWard = val;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedVehicleType = null;
    _selectedDivision = null;
    _selectedDistrict = null;
    _selectedUpazila = null;
    _selectedUnion = null;
    _selectedWard = null;
    notifyListeners();
  }

  void toggleLanguage() {
    _isBengali = !_isBengali;
    notifyListeners();
  }

  void toggleUnityMode(bool val) {
    _isUnityMode = val;
    notifyListeners();
  }
}
