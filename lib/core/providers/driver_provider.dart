import 'dart:async';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/material.dart';
import '../models/driver_model.dart';
import '../models/global_settings_model.dart';
import '../models/location_model.dart';
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

  // Union dropdown state (live Firestore data with bundled fallback)
  List<String> _unions = [];
  bool _isLoadingUnions = false;

  // Locations collection state (live Firestore data for custom upazilas, unions, wards)
  List<LocationModel> _customLocations = [];
  List<LocationModel> get customLocations => _customLocations;

  // Modes & Language
  bool _isBengali = true;
  bool _isUnityMode = false; // Home Mode vs Unity Mode

  // Notice Text & Global Settings
  String _noticeText = 'à¦¯à§‡à¦•à§‹à¦¨à§‹ à¦ªà§à¦°à¦¯à¦¼à§‹à¦œà¦¨ à¦¬à¦¾ à¦¸à¦¹à¦¾à¦¯à¦¼à¦¤à¦¾à¦° à¦œà¦¨à§à¦¯ à¦•à¦² à¦•à¦°à§à¦¨: 01677234252';
  GlobalSettingsModel _globalSettings = GlobalSettingsModel();
  List<VehicleTypeModel> _vehicleTypeModels = [];

  StreamSubscription? _driverSubscription;
  StreamSubscription? _settingsSubscription;
  StreamSubscription? _publicContentSubscription;
  StreamSubscription? _vehicleTypesSubscription;
  StreamSubscription? _locationsSubscription;
  StreamSubscription<List<String>>? _unionSubscription;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;
  bool _hasError = false;
  bool get hasError => _hasError;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    // 1. Listen to Real-time Firestore Active Drivers
    _driverSubscription = FirebaseService.streamActiveDrivers().listen(
      (firestoreDrivers) {
        _drivers = firestoreDrivers;
        _isLoading = false;
        _hasError = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (err) {
        debugPrint('Firestore drivers sync error: ${err.runtimeType}');
        _isLoading = false;
        _hasError = true;
        _errorMessage = _isBengali
            ? 'তথ্য লোড করতে সমস্যা হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।'
            : 'Failed to load data. Please try again.';
        notifyListeners();
      },
    );

    // 2. Listen to Real-time Settings (settings/global)
    _settingsSubscription = FirebaseService.listenGlobalSettings().listen(
      (doc) {
        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            _globalSettings = GlobalSettingsModel.fromMap(data);
            final liveText = data['noticeBn']?.toString() ?? data['liveBannerText']?.toString();
            final showBanner = data['showLiveBanner'] != false;
            if (showBanner && liveText != null && liveText.isNotEmpty) {
              _noticeText = liveText;
            }
            notifyListeners();
          }
        }
      },
      onError: (err) {
        debugPrint('Firestore settings sync error: ${err.runtimeType}');
      },
    );

    // 3. Listen to Real-time Public Content (settings/publicContent)
    _publicContentSubscription = FirebaseService.listenPublicContent().listen(
      (doc) {
        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            _globalSettings = _globalSettings.merge(data);
            final liveText = data['noticeBn']?.toString() ?? data['liveBannerText']?.toString();
            if (liveText != null && liveText.isNotEmpty) {
              _noticeText = liveText;
            }
            notifyListeners();
          }
        }
      },
      onError: (err) {
        debugPrint('Firestore public content sync error: ${err.runtimeType}');
      },
    );

    // 4. Listen to Real-time Vehicle Types (priority, monthly fee, discounts)
    _vehicleTypesSubscription = FirebaseService.streamVehicleTypes().listen(
      (list) {
        _vehicleTypeModels =
            list.map((m) => VehicleTypeModel.fromMap(m)).toList();
        notifyListeners();
      },
      onError: (err) {
        debugPrint('Firestore vehicleTypes sync error: ${err.runtimeType}');
      },
    );

    // 5. Listen to Real-time Locations (custom upazila, pourashava, union, ward)
    _locationsSubscription = FirebaseService.streamCustomLocations().listen(
      (locations) {
        _customLocations = locations;
        notifyListeners();
      },
      onError: (err) {
        debugPrint('Firestore custom locations sync error: ${err.runtimeType}');
      },
    );
  }

  /// Refreshes Firestore-backed data without resetting user form input or filter selections
  Future<void> refreshData() async {
    _isRefreshing = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      // A. Re-fetch combined global and publicContent settings
      final settingsData = await FirebaseService.fetchCombinedSettings();
      if (settingsData.isNotEmpty) {
        _globalSettings = GlobalSettingsModel.fromMap(settingsData);
        final liveText = settingsData['noticeBn']?.toString() ??
            settingsData['liveBannerText']?.toString();
        final showBanner = settingsData['showLiveBanner'] != false;
        if (showBanner && liveText != null && liveText.isNotEmpty) {
          _noticeText = liveText;
        }
      }

      // B. Re-fetch vehicle types with priority
      final vtList = await FirebaseService.fetchVehicleTypesOnce();
      if (vtList.isNotEmpty) {
        _vehicleTypeModels = vtList.map((m) => VehicleTypeModel.fromMap(m)).toList();
      }

      // C. Re-fetch active drivers
      final activeDrivers = await FirebaseService.fetchActiveDriversOnce();
      if (activeDrivers.isNotEmpty) {
        _drivers = activeDrivers;
      }

      // D. Sync remote geo hierarchy
      await GeoService.syncWithRemoteServer();

      // E. If an upazila is selected, refresh unions from cloud
      if (_selectedUpazila != null) {
        final bnDivision = _selectedDivision != null
            ? AppStrings.toBengaliDivision(_selectedDivision!)
            : '';
        final bnDistrict = _selectedDistrict != null
            ? AppStrings.toBengaliDistrict(_selectedDistrict!)
            : '';
        final unions = await UnionApiService.getUnions(
          divisionBn: bnDivision,
          districtBn: bnDistrict,
          upazilaName: _selectedUpazila!,
          isBengali: _isBengali,
        );
        if (unions.isNotEmpty) {
          _unions = unions;
        }
      }

      // F. Re-fetch custom locations from Firestore
      final freshLocations = await FirebaseService.fetchCustomLocationsOnce();
      if (freshLocations.isNotEmpty) {
        _customLocations = freshLocations;
      }
    } catch (e) {
      debugPrint('DriverProvider refreshData error: ${e.runtimeType}');
      _hasError = true;
      _errorMessage = _isBengali
          ? 'তথ্য লোড করতে সমস্যা হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।'
          : 'Failed to load data. Please try again.';
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _driverSubscription?.cancel();
    _settingsSubscription?.cancel();
    _publicContentSubscription?.cancel();
    _vehicleTypesSubscription?.cancel();
    _locationsSubscription?.cancel();
    _unionSubscription?.cancel();
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
    if (v.contains('ট্রাক্টর') ||
        v.contains('tractor') ||
        v.contains('কৃষি') ||
        v.contains('agriculture') ||
        v.contains('ভটভটি') ||
        v.contains('হারভেস্টার') ||
        v.contains('পাওয়ার টিলার') ||
        v.contains('টিলার') ||
        v.contains('এক্সকাভেটর') ||
        v.contains('ভেকু') ||
        v.contains('ট্রলি')) {
      return false;
    }
    return v == 'truck' ||
        v == 'pickup' ||
        v == 'ট্রাক' ||
        v == 'পিকআপ' ||
        (v.contains('ট্রাক') && !v.contains('ট্রাক্টর')) ||
        v.contains('পিকআপ') ||
        v.contains('কাভার্ড') ||
        v.contains('covered');
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
  List<String> get unions {
    final baseList = _isBengali
        ? _unions
        : _unions.map((u) => AppStrings.translateUnionStatic(u, false)).toList();

    if (_selectedUpazila == null || _selectedDistrict == null) return baseList;

    final div = _selectedDivision ?? '';
    final dist = _selectedDistrict!;
    final upz = _selectedUpazila!;

    // Find custom unions, pourashavas, and child locations (wards/areas)
    // under this selected upazila/pourashava from locations collection
    final customUnions = _customLocations.where((loc) {
      final lvl = loc.level;
      if (lvl == 'division' || lvl == 'district' || lvl == 'upazila') return false;

      // 1. Check parentRef if present
      if (loc.parentRef != null) {
        final parsed = LocationModel.parseParentRef(loc.parentRef);
        if (parsed != null) {
          final pDiv = parsed['division'] ?? '';
          final pDist = parsed['district'] ?? '';
          final pUpz = parsed['parent'] ?? '';
          if (pDiv.isNotEmpty && div.isNotEmpty && !AppStrings.areSameDivision(pDiv, div)) return false;
          if (pDist.isNotEmpty && dist.isNotEmpty && !AppStrings.areSameDistrict(pDist, dist)) return false;
          return _isMatchingLocationName(pUpz, upz);
        }
      }

      // 2. Legacy / field matching
      final locDiv = loc.effectiveDivision;
      if (locDiv.isNotEmpty && div.isNotEmpty && !AppStrings.areSameDivision(locDiv, div)) {
        return false;
      }
      final locDist = loc.effectiveDistrict;
      if (locDist.isNotEmpty && dist.isNotEmpty && !AppStrings.areSameDistrict(locDist, dist)) {
        return false;
      }
      final locUpz = loc.effectiveUpazila;
      if (locUpz.isEmpty) return false;
      return _isMatchingLocationName(locUpz, upz);
    }).map((loc) => loc.displayName(_isBengali)).where((name) => name.trim().isNotEmpty);

    final seen = <String>{};
    final combined = <String>[];
    for (final u in [...baseList, ...customUnions]) {
      final norm = BangladeshUnionsData.normalizeBn(u).toLowerCase();
      if (norm.isNotEmpty && seen.add(norm)) {
        combined.add(u);
      }
    }
    return combined;
  }
  bool get isLoadingUnions => _isLoadingUnions;
  bool get isUnityMode => _isUnityMode;
  String get noticeText => getNoticeText(_isBengali);

  String getNoticeText(bool isBn) {
    final text = _globalSettings.getNoticeText(isBn);
    if (text.isNotEmpty) return text;
    return _noticeText;
  }
  GlobalSettingsModel get globalSettings => _globalSettings;
  List<VehicleTypeModel> get vehicleTypeModels => _vehicleTypeModels;

  // Bangladesh Division -> District -> Upazila Geographic Mapping
  // Powered by GeoService (Offline-First Hive Cache + bangladesh.gov.bd dataset + Remote Sync)
  static Map<String, Map<String, List<String>>> get geoHierarchy =>
      GeoService.getHierarchy();

  // Preset Filter Options: Dynamic translation based on current language and sorted by priority
  List<String> get vehicleTypes {
    final activeModels = _vehicleTypeModels.where((v) => v.isVisible && v.isActive).toList();
    final modelsToUse = activeModels.isNotEmpty ? activeModels : _vehicleTypeModels;
    if (modelsToUse.isNotEmpty) {
      final sortedList = List<VehicleTypeModel>.from(modelsToUse);
      sortedList.sort((a, b) {
        final aPriority = a.priority ?? 999999;
        final bPriority = b.priority ?? 999999;
        final priorityCmp = aPriority.compareTo(bPriority);
        if (priorityCmp != 0) return priorityCmp;
        final aName = a.name.toLowerCase();
        final bName = b.name.toLowerCase();
        final nameCmp = aName.compareTo(bName);
        if (nameCmp != 0) return nameCmp;
        return a.id.compareTo(b.id);
      });
      return sortedList.map((v) => v.getDisplayName(_isBengali)).toSet().toList();
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
    final baseUpazilas = _isBengali
        ? rawUpazilas.map((u) => AppStrings.translateUpazilaStatic(u, true)).toList()
        : rawUpazilas.map((u) => AppStrings.translateUpazilaStatic(u, false)).toList();

    // Include custom upazilas / pourashavas from locations collection matching this district
    final customUpz = _customLocations
        .where((loc) {
          final lvl = loc.level;
          if (lvl != 'upazila' && lvl != 'pourashava') return false;
          final locDist = loc.effectiveDistrict;
          if (locDist.isNotEmpty && !AppStrings.areSameDistrict(locDist, district)) {
            return false;
          }
          final locDiv = loc.effectiveDivision;
          if (locDiv.isNotEmpty && division.isNotEmpty && !AppStrings.areSameDivision(locDiv, division)) {
            return false;
          }
          return true;
        })
        .map((loc) => loc.displayName(_isBengali))
        .where((name) => name.trim().isNotEmpty);

    final seen = <String>{};
    final result = <String>[];
    for (final u in [...baseUpazilas, ...customUpz]) {
      final norm = BangladeshUnionsData.normalizeBn(u).toLowerCase();
      if (norm.isNotEmpty && seen.add(norm)) {
        result.add(u);
      }
    }
    return result;
  }

  // Cascading wards: dynamically read child locations from locations collection for the selected parent.
  // Never returns hardcoded fake options; returns empty list if no child locations exist.
  List<String> get wards {
    if (_selectedDistrict == null) return [];

    final directParent = (_selectedUnion != null && _selectedUnion!.trim().isNotEmpty)
        ? _selectedUnion!.trim()
        : ((_selectedUpazila != null && _selectedUpazila!.trim().isNotEmpty)
            ? _selectedUpazila!.trim()
            : null);

    if (directParent == null) return [];

    return getWardsForParent(
      division: _selectedDivision ?? '',
      district: _selectedDistrict!,
      parentName: directParent,
    );
  }

  /// Standard Ward selector options for the Home filter.
  List<String> get driverWardOptions =>
      List<String>.generate(60, (index) => '${index + 1}');

  /// Get direct child wards/locations for a specific parent (union or pourashava/upazila)
  List<String> getWardsForParent({
    required String division,
    required String district,
    required String parentName,
  }) {
    if (district.isEmpty || parentName.isEmpty) return [];

    final matchingWards = _customLocations.where((loc) {
      final lvl = loc.level;
      if (lvl != 'ward' && lvl != 'gram' && lvl != 'village' && lvl != 'area') return false;

      // 1. Check parentRef if present
      if (loc.parentRef != null && loc.parentRef!.startsWith('upazila:')) {
        final parsed = LocationModel.parseParentRef(loc.parentRef);
        if (parsed != null) {
          final pDiv = parsed['division'] ?? '';
          final pDist = parsed['district'] ?? '';
          final pName = parsed['parent'] ?? '';
          if (pDiv.isNotEmpty && division.isNotEmpty && !AppStrings.areSameDivision(pDiv, division)) return false;
          if (pDist.isNotEmpty && !AppStrings.areSameDistrict(pDist, district)) return false;
          return _isMatchingLocationName(pName, parentName);
        }
      }

      // 2. Legacy / field matching
      final locDiv = loc.effectiveDivision;
      if (locDiv.isNotEmpty && division.isNotEmpty && !AppStrings.areSameDivision(locDiv, division)) {
        return false;
      }
      final locDist = loc.effectiveDistrict;
      if (locDist.isNotEmpty && !AppStrings.areSameDistrict(locDist, district)) {
        return false;
      }

      final parentCandidates = [
        loc.parentUpazila,
        loc.union,
        loc.upazila,
        loc.parentId,
      ].whereType<String>().where((s) => s.trim().isNotEmpty).toList();

      if (parentCandidates.isEmpty) return false;
      return parentCandidates.any((p) => _isMatchingLocationName(p, parentName));
    }).map((loc) => loc.displayName(_isBengali)).where((name) => name.trim().isNotEmpty);

    final seen = <String>{};
    final result = <String>[];
    for (final w in matchingWards) {
      final norm = BangladeshUnionsData.normalizeBn(w).toLowerCase();
      if (norm.isNotEmpty && seen.add(norm)) {
        result.add(w);
      }
    }
    return result;
  }

  static bool _isMatchingLocationName(String a, String b) {
    if (a.trim().toLowerCase() == b.trim().toLowerCase()) return true;
    final normA = BangladeshUnionsData.normalizeBn(a).toLowerCase();
    final normB = BangladeshUnionsData.normalizeBn(b).toLowerCase();
    if (normA == normB) return true;
    if (AppStrings.areSameUpazila(a, b)) return true;

    // Suffix stripping (e.g. 'পৌরসভা', 'সদর', 'pourashava', 'sadar', etc.)
    final cleanA = _stripLocationSuffix(normA);
    final cleanB = _stripLocationSuffix(normB);
    if (cleanA.isNotEmpty && cleanA == cleanB) return true;
    if (AppStrings.areSameUpazila(cleanA, cleanB)) return true;

    // Transliteration & English consonant skeleton matching (e.g. 'madripur' vs 'madirpur' vs 'madaripur' vs 'মাদারীপুর')
    if (_matchPhoneticOrSkeleton(cleanA, cleanB)) return true;

    return false;
  }

  static String _stripLocationSuffix(String s) {
    return s
        .replaceAll(
            RegExp(r'\s*\(?(পৌরসভা|pourashava|municipality|সদর|sadar|মডেল|model|থানা|thana)\)?',
                caseSensitive: false),
            '')
        .trim();
  }

  static bool _matchPhoneticOrSkeleton(String a, String b) {
    String enA = AppStrings.translateUpazilaStatic(a, false).toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    String enB = AppStrings.translateUpazilaStatic(b, false).toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (enA.isEmpty) enA = a.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (enB.isEmpty) enB = b.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (enA.isNotEmpty && enA == enB) return true;

    // Consonant skeleton (strip vowels)
    final skelA = enA.replaceAll(RegExp(r'[aeiouy]'), '');
    final skelB = enB.replaceAll(RegExp(r'[aeiouy]'), '');
    if (skelA.length >= 3 && skelA == skelB) return true;

    return false;
  }

  static String _westernizeDigits(String value) => value.replaceAllMapped(
        RegExp(r'[০-৯]'),
        (match) => '${match.group(0)!.codeUnitAt(0) - '০'.codeUnitAt(0)}',
      );

  static bool _matchesWardNumber(String wardValue, String selectedNumber) {
    final normalizedWard = _westernizeDigits(wardValue.trim());
    final wardNumbers = RegExp(r'\d+')
        .allMatches(normalizedWard)
        .map((match) => match.group(0))
        .whereType<String>();
    return wardNumbers.contains(selectedNumber);
  }

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
          final mEn = m.enName.trim().toLowerCase();
          final isSel = sel == mName || (mBn.isNotEmpty && sel == mBn) || (mEn.isNotEmpty && sel == mEn);
          final isDType = dType == mName || (mBn.isNotEmpty && dType == mBn) || (mEn.isNotEmpty && dType == mEn);
          if (isSel && isDType) {
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

      final selectedWard = _selectedWard?.trim() ?? '';
      final matchesWard = selectedWard.isEmpty ||
          _matchesWardNumber(driver.ward, selectedWard);

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
    _unionSubscription?.cancel();
    _selectedDivision = val;
    _searchCycleCounter++;
    _selectedDistrict = null; // Reset child district
    _selectedUpazila = null;  // Reset child upazila
    _selectedUnion = null;    // Reset union
    _selectedWard = null;     // Reset child ward
    _unions = [];             // Clear union list
    _isLoadingUnions = false;
    notifyListeners();
  }

  void setDistrict(String? val) {
    _unionSubscription?.cancel();
    _selectedDistrict = val;
    _searchCycleCounter++;
    _selectedUpazila = null;  // Reset child upazila
    _selectedUnion = null;    // Reset union
    _selectedWard = null;     // Reset child ward
    _unions = [];             // Clear union list
    _isLoadingUnions = false;
    notifyListeners();
  }

  void setUpazila(String? val) {
    _unionSubscription?.cancel();
    _selectedUpazila = val;
    _searchCycleCounter++;
    _selectedUnion = null; // Reset union when upazila changes
    _selectedWard = null;  // Reset ward when upazila changes
    _unions = [];
    // Subscribe to Firestore union changes for the selected upazila.
    if (val != null) {
      _fetchUnions(val);
    }
    notifyListeners();
  }

  /// Listen for union list updates for the currently selected upazila.
  void _fetchUnions(String upazila) {
    _isLoadingUnions = true;
    notifyListeners();
    final bnDivision = _selectedDivision != null
        ? AppStrings.toBengaliDivision(_selectedDivision!)
        : '';
    final bnDistrict = _selectedDistrict != null
        ? AppStrings.toBengaliDistrict(_selectedDistrict!)
        : '';
    _unionSubscription = UnionApiService.watchUnions(
        divisionBn: bnDivision,
        districtBn: bnDistrict,
        upazilaName: upazila,
        isBengali: _isBengali,
      ).listen((unions) {
        if (_selectedUpazila != upazila) return;
        _unions = unions;
        _isLoadingUnions = false;
        notifyListeners();
      }, onError: (Object error) async {
        debugPrint('DriverProvider union listener error: ${error.runtimeType}');
        final fallback = await UnionApiService.getUnions(
          divisionBn: bnDivision,
          districtBn: bnDistrict,
          upazilaName: upazila,
          isBengali: _isBengali,
        );
        if (_selectedUpazila != upazila) return;
        _unions = fallback;
        _isLoadingUnions = false;
        notifyListeners();
      });
  }

  void setUnion(String? val) {
    _selectedUnion = val;
    _selectedWard = null; // Reset ward when union changes
    _searchCycleCounter++;
    notifyListeners();
  }

  void setWard(String? val) {
    _selectedWard = val;
    _searchCycleCounter++;
    notifyListeners();
  }

  void resetFilters() {
    _unionSubscription?.cancel();
    _searchQuery = '';
    _selectedVehicleType = null;
    _selectedDivision = null;
    _selectedDistrict = null;
    _selectedUpazila = null;
    _selectedUnion = null;
    _selectedWard = null;
    _unions = [];
    _isLoadingUnions = false;
    _isCoveredFilter = false;
    _vehicleLengthFilter = '';
    _isAirAmbulanceFilter = false;
    _isSelfDrivingFilter = false;
    _searchCycleCounter++;
    notifyListeners();
  }

  Future<void> resetToHomeAndRefresh() async {
    resetFilters();
    await refreshData();
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
