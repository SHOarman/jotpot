import 'dart:async';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../models/global_settings_model.dart';
import '../models/vehicle_type_model.dart';
import '../services/firebase_service.dart';
import '../services/geo_service.dart';
import '../services/hive_service.dart';
import '../services/union_api_service.dart';
import '../../utils/app_strings.dart';

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

  // Union dropdown state (loaded from BD API when upazila is selected)
  List<String> _unions = [];
  bool _isLoadingUnions = false;

  // Modes & Language
  bool _isBengali = true;
  bool _isUnityMode = false; // Home Mode vs Unity Mode

  // Notice Text & Global Settings
  String _noticeText = 'à¦¯à§‡à¦•à§‹à¦¨à§‹ à¦ªà§à¦°à¦¯à¦¼à§‹à¦œà¦¨ à¦¬à¦¾ à¦¸à¦¹à¦¾à¦¯à¦¼à¦¤à¦¾à¦° à¦œà¦¨à§à¦¯ à¦•à¦² à¦•à¦°à§à¦¨: 01677234252';
  GlobalSettingsModel _globalSettings = GlobalSettingsModel();
  List<VehicleTypeModel> _vehicleTypeModels = [];

  StreamSubscription? _driverSubscription;
  StreamSubscription? _settingsSubscription;
  StreamSubscription? _vehicleTypesSubscription;

  DriverProvider() {
    loadDrivers();
    _initFirestore();
    GeoService.syncWithRemoteServer(
      onUpdated: () => notifyListeners(),
    );
  }

  void _initFirestore() {
    if (Firebase.apps.isEmpty) {
      debugPrint('Firebase not initialized yet. Skipping Firestore listener setup.');
      return;
    }

    _isLoading = true;
    notifyListeners();

    // 1. Listen to Real-time Firestore Active Drivers
    _driverSubscription = FirebaseService.streamActiveDrivers().listen(
      (firestoreDrivers) {
        _drivers = firestoreDrivers;
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        debugPrint('Firestore drivers sync error: $err');
        _isLoading = false;
        notifyListeners();
      },
    );

    // 2. Listen to Real-time Settings (Payment instructions, automated payments, discounts, live banner)
    _settingsSubscription = FirebaseService.listenGlobalSettings().listen(
      (doc) {
        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            _globalSettings = GlobalSettingsModel.fromMap(data);
            final liveText = data['liveBannerText']?.toString();
            final showBanner = data['showLiveBanner'] == true;
            if (showBanner && liveText != null && liveText.isNotEmpty) {
              _noticeText = liveText;
            }
            notifyListeners();
          }
        }
      },
      onError: (err) {
        debugPrint('Firestore settings sync error: $err');
      },
    );

    // 3. Listen to Real-time Vehicle Types (Monthly fee, discounts)
    _vehicleTypesSubscription = FirebaseService.streamVehicleTypes().listen(
      (list) {
        _vehicleTypeModels =
            list.map((m) => VehicleTypeModel.fromMap(m)).toList();
        notifyListeners();
      },
      onError: (err) {
        debugPrint('Firestore vehicleTypes sync error: $err');
      },
    );
  }

  @override
  void dispose() {
    _driverSubscription?.cancel();
    _settingsSubscription?.cancel();
    _vehicleTypesSubscription?.cancel();
    super.dispose();
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
  List<String> get unions => _unions;
  bool get isLoadingUnions => _isLoadingUnions;
  bool get isUnityMode => _isUnityMode;
  String get noticeText => _noticeText;
  GlobalSettingsModel get globalSettings => _globalSettings;
  List<VehicleTypeModel> get vehicleTypeModels => _vehicleTypeModels;

  // Bangladesh Division -> District -> Upazila Geographic Mapping
  // Powered by GeoService (Offline-First Hive Cache + bangladesh.gov.bd dataset + Remote Sync)
  static Map<String, Map<String, List<String>>> get geoHierarchy =>
      GeoService.getHierarchy();

  // Preset Filter Options: Dynamic translation based on current language
  List<String> get vehicleTypes {
    final rawList = _vehicleTypeModels.isNotEmpty
        ? _vehicleTypeModels.map((v) => v.name).toList()
        : [
            'Bus',
            'Car',
            'Microbus',
            'CNG',
            'Truck',
            'Ambulance',
            'Bike',
            'Pickup',
          ];
    return rawList
        .map((vt) => AppStrings.translateVehicleTypeStatic(vt, _isBengali))
        .toSet()
        .toList();
  }

  // All divisions translated dynamically
  List<String> get divisions {
    final bnDivisions = geoHierarchy.keys.toList();
    if (_isBengali) {
      return bnDivisions;
    } else {
      return bnDivisions
          .map((d) => AppStrings.translateDivisionStatic(d, false))
          .toList();
    }
  }

  // Cascading districts: Only shown if division is selected
  List<String> get districts {
    if (_selectedDivision == null) return [];
    return getDistrictsForDivision(_selectedDivision!);
  }

  // Cascading upazilas: Only shown if district is selected
  List<String> get upazilas {
    if (_selectedDivision == null || _selectedDistrict == null) return [];
    return getUpazilasForDistrict(_selectedDivision!, _selectedDistrict!);
  }

  // Helper for Cascading Districts (Used by Filter Section & Registration Dialog)
  List<String> getDistrictsForDivision(String division) {
    final bnDivision = AppStrings.toBengaliDivision(division);
    final rawDistricts = geoHierarchy[bnDivision]?.keys.toList() ?? [];
    if (_isBengali) {
      return rawDistricts;
    } else {
      return rawDistricts
          .map((d) => AppStrings.translateDistrictStatic(d, false))
          .toList();
    }
  }

  // Helper for Cascading Upazilas (Used by Filter Section & Registration Dialog)
  List<String> getUpazilasForDistrict(String division, String district) {
    final bnDivision = AppStrings.toBengaliDivision(division);
    final bnDistrict = AppStrings.toBengaliDistrict(district);
    final rawUpazilas = geoHierarchy[bnDivision]?[bnDistrict] ?? [];
    if (_isBengali) {
      return rawUpazilas
          .map((u) => AppStrings.translateUpazilaStatic(u, true))
          .toList();
    } else {
      return rawUpazilas
          .map((u) => AppStrings.translateUpazilaStatic(u, false))
          .toList();
    }
  }

  List<String> get wards => [
        'à¦“à§Ÿà¦¾à¦°à§à¦¡ à§§',
        'à¦“à§Ÿà¦¾à¦°à§à¦¡ à§¨',
        'à¦“à§Ÿà¦¾à¦°à§à¦¡ à§©',
        'à¦“à§Ÿà¦¾à¦°à§à¦¡ à§ª',
        'à¦“à§Ÿà¦¾à¦°à§à¦¡ à§«',
        'à¦“à§Ÿà¦¾à¦°à§à¦¡ à§¬',
        'à¦“à§Ÿà¦¾à¦°à§à¦¡ à§­',
        'à¦“à§Ÿà¦¾à¦°à§à¦¡ à§®',
        'à¦“à§Ÿà¦¾à¦°à§à¦¡ à§¯',
      ];

  /// Filtered drivers getter
  List<DriverModel> get filteredDrivers {
    return _drivers.where((driver) {
      final matchesSearch = _searchQuery.isEmpty ||
          driver.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          driver.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          driver.upazila.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          driver.union.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          driver.ward.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          AppStrings.translateDivisionStatic(driver.division, true)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          AppStrings.translateDivisionStatic(driver.division, false)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          AppStrings.translateDistrictStatic(driver.district, true)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          AppStrings.translateDistrictStatic(driver.district, false)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          AppStrings.translateUpazilaStatic(driver.upazila, true)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          AppStrings.translateUpazilaStatic(driver.upazila, false)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      final matchesVehicle = _selectedVehicleType == null ||
          driver.vehicleType == _selectedVehicleType ||
          AppStrings.areSameVehicleType(
              driver.vehicleType, _selectedVehicleType!);

      final matchesDivision = _selectedDivision == null ||
          driver.division == _selectedDivision ||
          AppStrings.areSameDivision(driver.division, _selectedDivision!);

      final matchesDistrict = _selectedDistrict == null ||
          driver.district == _selectedDistrict ||
          AppStrings.areSameDistrict(driver.district, _selectedDistrict!);

      final matchesUpazila = _selectedUpazila == null ||
          driver.upazila == _selectedUpazila ||
          AppStrings.areSameUpazila(driver.upazila, _selectedUpazila!);

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

  /// Load drivers (empty until Firestore emits real data)
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

  /// Add new driver (Firestore + Hive)
  Future<void> addDriver(DriverModel driver) async {
    try {
      await FirebaseService.registerDriver(
        name: driver.name,
        phone: driver.phone,
        vehicleType: driver.vehicleType,
        division: driver.division,
        district: driver.district,
        upazila: driver.upazila,
        union: driver.union,
        ward: driver.ward,
      );
    } catch (e) {
      debugPrint('Firestore registerDriver error: $e');
    }
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
    _selectedUnion = null;    // Reset union
    _unions = [];             // Clear union list
    _isLoadingUnions = false;
    notifyListeners();
  }

  void setDistrict(String? val) {
    _selectedDistrict = val;
    _selectedUpazila = null;  // Reset child upazila
    _selectedUnion = null;    // Reset union
    _unions = [];             // Clear union list
    _isLoadingUnions = false;
    notifyListeners();
  }

  void setUpazila(String? val) {
    _selectedUpazila = val;
    _selectedUnion = null; // Reset union when upazila changes
    _unions = [];
    // Fetch unions from BD API when upazila is selected
    if (val != null &&
        _selectedDivision != null &&
        _selectedDistrict != null) {
      _fetchUnions(val);
    }
    notifyListeners();
  }

  /// Fetch union list from BD API for the currently selected upazila.
  Future<void> _fetchUnions(String upazila) async {
    _isLoadingUnions = true;
    notifyListeners();
    try {
      _unions = await UnionApiService.getUnions(
        divisionBn: _selectedDivision ?? '',
        districtBn: _selectedDistrict ?? '',
        upazilaName: upazila,
      );
    } catch (e) {
      debugPrint('DriverProvider _fetchUnions error: $e');
      _unions = [];
    } finally {
      _isLoadingUnions = false;
      notifyListeners();
    }
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
    // Seamlessly translate currently selected filters to the newly selected language
    if (_selectedDivision != null) {
      _selectedDivision =
          AppStrings.translateDivisionStatic(_selectedDivision!, _isBengali);
    }
    if (_selectedDistrict != null) {
      _selectedDistrict =
          AppStrings.translateDistrictStatic(_selectedDistrict!, _isBengali);
    }
    if (_selectedUpazila != null) {
      _selectedUpazila =
          AppStrings.translateUpazilaStatic(_selectedUpazila!, _isBengali);
    }
    if (_selectedVehicleType != null) {
      _selectedVehicleType = AppStrings.translateVehicleTypeStatic(
          _selectedVehicleType!, _isBengali);
    }
    notifyListeners();
  }

  void toggleUnityMode(bool val) {
    _isUnityMode = val;
    notifyListeners();
  }
}
