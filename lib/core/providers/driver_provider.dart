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
import '../data/bangladesh_unions_data.dart';
import '../../utils/app_strings.dart';

class DriverProvider extends ChangeNotifier {
  List<DriverModel> _drivers = [];
  bool _isLoading = false;
  int _searchCycleCounter = 0;

  // Search & Filters
  String _searchQuery = '';
  String? _selectedVehicleType;
  String? _selectedDivision;
  String? _selectedDistrict;
  String? _selectedUpazila;
  String? _selectedUnion;
  String? _selectedWard;

  // Extra Feature Filters (Covered, Length, Air Ambulance, Self Driving)
  bool _isCoveredFilter = false;
  String _vehicleLengthFilter = '';
  bool _isAirAmbulanceFilter = false;
  bool _isSelfDrivingFilter = false;

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
    GeoService.listenToRemoteUpdates(
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

  // Extra Feature Filters Getters & State Helpers
  bool get isCoveredFilter => _isCoveredFilter;
  String get vehicleLengthFilter => _vehicleLengthFilter;
  bool get isAirAmbulanceFilter => _isAirAmbulanceFilter;
  bool get isSelfDrivingFilter => _isSelfDrivingFilter;

  bool get isSelectedTruckOrPickup {
    if (_selectedVehicleType == null) return false;
    final v = _selectedVehicleType!.trim().toLowerCase();
    return v == 'truck' || v == 'pickup' || v.contains('ট্রাক') || v.contains('পিকআপ') || v.contains('কাভার্ড');
  }

  bool get isSelectedHelicopter {
    if (_selectedVehicleType == null) return false;
    final v = _selectedVehicleType!.trim().toLowerCase();
    return v == 'helicopter' || v.contains('হেলিকপ্টার');
  }

  bool get isSelectedMotorcycleOrCar {
    if (_selectedVehicleType == null) return false;
    final v = _selectedVehicleType!.trim().toLowerCase();
    return v == 'motorcycle' || v == 'bike' || v == 'car' || v == 'private car' || v.contains('মোটরসাইকেল') || v.contains('বাইক') || v.contains('কার') || v.contains('প্রাইভেট');
  }
  List<String> get unions => _isBengali
      ? _unions
      : _unions.map((u) => AppStrings.translateUnionStatic(u, false)).toList();
  bool get isLoadingUnions => _isLoadingUnions;
  bool get isUnityMode => _isUnityMode;
  String get noticeText => getNoticeText(_isBengali);

  String getNoticeText(bool isBn) {
    if (isBn) {
      if (_globalSettings.liveBannerText.isNotEmpty) {
        return _globalSettings.liveBannerText;
      }
      if (_noticeText.isNotEmpty) return _noticeText;
      final phone = _globalSettings.contactPhone.isNotEmpty
          ? _globalSettings.contactPhone
          : '01677234297';
      return 'যেকোনো প্রয়োজন বা সহায়তার জন্য ঝটপট-এর সাথে সরাসরি যোগাযোগ করুন। কল করুন: $phone';
    } else {
      if (_globalSettings.liveBannerTextEn.isNotEmpty) {
        return _globalSettings.liveBannerTextEn;
      }
      final phone = _globalSettings.contactPhone.isNotEmpty
          ? _globalSettings.contactPhone
          : '01677234297';
      return 'For any inquiry or assistance, please contact Jotpot directly. Call: $phone';
    }
  }
  GlobalSettingsModel get globalSettings => _globalSettings;
  List<VehicleTypeModel> get vehicleTypeModels => _vehicleTypeModels;

  // Bangladesh Division -> District -> Upazila Geographic Mapping
  // Powered by GeoService (Offline-First Hive Cache + bangladesh.gov.bd dataset + Remote Sync)
  static Map<String, Map<String, List<String>>> get geoHierarchy =>
      GeoService.getHierarchy();

  // Preset Filter Options: Dynamic translation based on current language
  List<String> get vehicleTypes {
    final activeModels = _vehicleTypeModels.where((v) => v.isVisible && v.isActive).toList();
    final modelsToUse = activeModels.isNotEmpty ? activeModels : _vehicleTypeModels;
    if (modelsToUse.isNotEmpty) {
      return modelsToUse.map((v) {
        if (_isBengali) {
          if (v.bnName.trim().isNotEmpty) return v.bnName.trim();
          return AppStrings.translateVehicleTypeStatic(v.name, true);
        } else {
          return AppStrings.translateVehicleTypeStatic(v.name, false);
        }
      }).toSet().toList();
    }
    final defaultList = [
      'Bus',
      'Car',
      'Microbus',
      'CNG',
      'Truck',
      'Ambulance',
      'Bike',
      'Pickup',
    ];
    return defaultList
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
    Map<String, List<String>>? districtMap;
    for (final entry in geoHierarchy.entries) {
      if (AppStrings.areSameDivision(entry.key, division)) {
        districtMap = entry.value;
        break;
      }
    }
    districtMap ??= geoHierarchy[AppStrings.toBengaliDivision(division)];
    final rawDistricts = districtMap?.keys.toList() ?? [];
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
    Map<String, List<String>>? districtMap;
    for (final entry in geoHierarchy.entries) {
      if (AppStrings.areSameDivision(entry.key, division)) {
        districtMap = entry.value;
        break;
      }
    }
    List<String>? upazilaList;
    if (districtMap != null) {
      for (final entry in districtMap.entries) {
        if (AppStrings.areSameDistrict(entry.key, district)) {
          upazilaList = entry.value;
          break;
        }
      }
    }
    final rawUpazilas = upazilaList ?? [];
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

  List<String> get wards => _isBengali
      ? const [
          'ওয়ার্ড ১',
          'ওয়ার্ড ২',
          'ওয়ার্ড ৩',
          'ওয়ার্ড ৪',
          'ওয়ার্ড ৫',
          'ওয়ার্ড ৬',
          'ওয়ার্ড ৭',
          'ওয়ার্ড ৮',
          'ওয়ার্ড ৯',
        ]
      : const [
          'Ward 1',
          'Ward 2',
          'Ward 3',
          'Ward 4',
          'Ward 5',
          'Ward 6',
          'Ward 7',
          'Ward 8',
          'Ward 9',
        ];

  /// Filtered drivers getter
  List<DriverModel> get filteredDrivers {
    final list = _drivers.where((driver) {
      if (!driver.isActive) return false;
      final isAllFree = _globalSettings.allVehiclesFree == true;
      if (!isAllFree && driver.expiryDate != null && driver.expiryDate!.year <= 2090) {
        if (driver.expiryDate!.isBefore(DateTime.now())) {
          return false;
        }
      }
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

      bool matchesVehicle = _selectedVehicleType == null ||
          driver.vehicleType == _selectedVehicleType ||
          AppStrings.areSameVehicleType(
              driver.vehicleType, _selectedVehicleType!);
      if (!matchesVehicle && _selectedVehicleType != null && _vehicleTypeModels.isNotEmpty) {
        final sel = _selectedVehicleType!.trim().toLowerCase();
        final dType = driver.vehicleType.trim().toLowerCase();
        for (final m in _vehicleTypeModels) {
          final mName = m.name.trim().toLowerCase();
          final mBn = m.bnName.trim().toLowerCase();
          if ((sel == mName || (mBn.isNotEmpty && sel == mBn)) &&
              (dType == mName || (mBn.isNotEmpty && dType == mBn))) {
            matchesVehicle = true;
            break;
          }
        }
      }

      final matchesDivision = _selectedDivision == null ||
          driver.division == _selectedDivision ||
          AppStrings.areSameDivision(driver.division, _selectedDivision!);

      final matchesDistrict = _selectedDistrict == null ||
          driver.district == _selectedDistrict ||
          AppStrings.areSameDistrict(driver.district, _selectedDistrict!);

      final selUpa = _selectedUpazila != null ? BangladeshUnionsData.normalizeBn(_selectedUpazila!) : null;
      final dUpa = BangladeshUnionsData.normalizeBn(driver.upazila);

      final matchesUpazila = selUpa == null ||
          selUpa.isEmpty ||
          dUpa == selUpa ||
          AppStrings.areSameUpazila(driver.upazila, _selectedUpazila!) ||
          (dUpa.isNotEmpty && (dUpa.contains(selUpa) || selUpa.contains(dUpa)));

      bool matchesUnion = true;
      if (_selectedUnion != null && _selectedUnion!.trim().isNotEmpty) {
        final sel = BangladeshUnionsData.normalizeBn(_selectedUnion!);
        final dUnion = BangladeshUnionsData.normalizeBn(driver.union);
        final dAddr = BangladeshUnionsData.normalizeBn(driver.address);
        final dWard = BangladeshUnionsData.normalizeBn(driver.ward);

        final isPourashavaFilter = BangladeshUnionsData.isPourashava(sel);

        if (isPourashavaFilter) {
          final pouroBase = sel.replaceAll('পৌরসভা', '').trim();
          final isExplicitRuralUnion = dUnion.isNotEmpty &&
              !BangladeshUnionsData.isPourashava(dUnion) &&
              !dUnion.contains('ওয়ার্ড') &&
              !dUnion.contains('ward') &&
              (pouroBase.isEmpty || !dUnion.contains(pouroBase));

          if (isExplicitRuralUnion) {
            matchesUnion = false;
          } else {
            matchesUnion = dUnion.contains('পৌরসভা') ||
                dUnion.contains('pouro') ||
                dUnion.contains('সিটি কর্পোরেশন') ||
                (pouroBase.isNotEmpty && dUnion.contains(pouroBase)) ||
                (pouroBase.isNotEmpty && dAddr.contains(pouroBase)) ||
                dAddr.contains('পৌরসভা') ||
                dWard.contains('পৌরসভা') ||
                dWard.isNotEmpty ||
                dUnion.isEmpty;
          }
        } else {
          matchesUnion = (dUnion.isNotEmpty && (dUnion.contains(sel) || sel.contains(dUnion))) ||
              dAddr.contains(sel) ||
              dWard.contains(sel);
        }
      }

      final matchesWard = _selectedWard == null ||
          _selectedWard!.trim().isEmpty ||
          driver.ward.toLowerCase().contains(_selectedWard!.trim().toLowerCase()) ||
          driver.address.toLowerCase().contains(_selectedWard!.trim().toLowerCase());

      // Feature specific filters
      if (_isCoveredFilter && !driver.isCovered) {
        return false;
      }
      if (_isCoveredFilter && _vehicleLengthFilter.trim().isNotEmpty) {
        final search = _vehicleLengthFilter.trim().toLowerCase();
        final searchDigits = search.replaceAll(RegExp(r'[^0-9]'), '');
        final dLen = driver.vehicleLength.trim().toLowerCase();
        final dDigits = dLen.replaceAll(RegExp(r'[^0-9]'), '');
        if (searchDigits.isNotEmpty && dDigits.isNotEmpty) {
          if (!dDigits.contains(searchDigits) && !dLen.contains(search)) {
            return false;
          }
        } else {
          if (!dLen.contains(search)) {
            return false;
          }
        }
      }
      if (_isAirAmbulanceFilter && !driver.isAirAmbulance) {
        return false;
      }
      if (_isSelfDrivingFilter && !driver.isSelfDriving) {
        return false;
      }

      return matchesSearch &&
          matchesVehicle &&
          matchesDivision &&
          matchesDistrict &&
          matchesUpazila &&
          matchesUnion &&
          matchesWard;
    }).toList();

    if (list.length <= 1) return list;

    // Fair Rotation & Dynamic Swapping:
    // Ensures that when multiple drivers are registered in the same location/vehicle category,
    // the top position dynamically swaps/alternates so every driver gets turns at the top (1st place)
    // both across searches and across 5-minute time slots.
    final now = DateTime.now();
    final timeSlot = (now.millisecondsSinceEpoch ~/ (1000 * 60 * 5));
    final rotationOffset = (timeSlot + _searchCycleCounter) % list.length;

    if (rotationOffset > 0) {
      return [
        ...list.sublist(rotationOffset),
        ...list.sublist(0, rotationOffset),
      ];
    }
    return list;
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
    _searchCycleCounter++;
    notifyListeners();
  }

  void setVehicleType(String? val) {
    _selectedVehicleType = val;
    // Reset vehicle-specific sub-filters when vehicle type changes
    _isCoveredFilter = false;
    _vehicleLengthFilter = '';
    _isAirAmbulanceFilter = false;
    _isSelfDrivingFilter = false;
    _searchCycleCounter++;
    notifyListeners();
  }

  void setIsCoveredFilter(bool val) {
    _isCoveredFilter = val;
    if (!val) {
      _vehicleLengthFilter = '';
    }
    _searchCycleCounter++;
    notifyListeners();
  }

  void setVehicleLengthFilter(String val) {
    _vehicleLengthFilter = val;
    _searchCycleCounter++;
    notifyListeners();
  }

  void setIsAirAmbulanceFilter(bool val) {
    _isAirAmbulanceFilter = val;
    _searchCycleCounter++;
    notifyListeners();
  }

  void setIsSelfDrivingFilter(bool val) {
    _isSelfDrivingFilter = val;
    _searchCycleCounter++;
    notifyListeners();
  }

  void setDivision(String? val) {
    _selectedDivision = val;
    _searchCycleCounter++;
    _selectedDistrict = null; // Reset child district
    _selectedUpazila = null;  // Reset child upazila
    _selectedUnion = null;    // Reset union
    _unions = [];             // Clear union list
    _isLoadingUnions = false;
    notifyListeners();
  }

  void setDistrict(String? val) {
    _selectedDistrict = val;
    _searchCycleCounter++;
    _selectedUpazila = null;  // Reset child upazila
    _selectedUnion = null;    // Reset union
    _unions = [];             // Clear union list
    _isLoadingUnions = false;
    notifyListeners();
  }

  void setUpazila(String? val) {
    _selectedUpazila = val;
    _searchCycleCounter++;
    _selectedUnion = null; // Reset union when upazila changes
    _unions = [];
    // Fetch unions from BD API when upazila is selected
    if (val != null) {
      _fetchUnions(val);
    }
    notifyListeners();
  }

  /// Fetch union list from BD API for the currently selected upazila.
  Future<void> _fetchUnions(String upazila) async {
    _isLoadingUnions = true;
    notifyListeners();
    try {
      final bnDivision = _selectedDivision != null ? AppStrings.toBengaliDivision(_selectedDivision!) : '';
      final bnDistrict = _selectedDistrict != null ? AppStrings.toBengaliDistrict(_selectedDistrict!) : '';
      final bnUpazila = AppStrings.translateUpazilaStatic(upazila, true);
      _unions = await UnionApiService.getUnions(
        divisionBn: bnDivision,
        districtBn: bnDistrict,
        upazilaName: bnUpazila,
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
    _searchCycleCounter++;
    notifyListeners();
  }

  void setWard(String? val) {
    _selectedWard = val;
    _searchCycleCounter++;
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
    _isCoveredFilter = false;
    _vehicleLengthFilter = '';
    _isAirAmbulanceFilter = false;
    _isSelfDrivingFilter = false;
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
    if (_selectedUnion != null) {
      _selectedUnion = AppStrings.translateUnionStatic(_selectedUnion!, _isBengali);
    }
    if (_selectedWard != null) {
      _selectedWard = AppStrings.translateWardStatic(_selectedWard!, _isBengali);
    }
    notifyListeners();
  }

  void toggleUnityMode(bool val) {
    _isUnityMode = val;
    notifyListeners();
  }
}
