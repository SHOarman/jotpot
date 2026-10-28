import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_connect/connect.dart';
import '../data/bangladesh_geo_data.dart';
import 'hive_service.dart';

class GeoService {
  static Map<String, Map<String, List<String>>> _currentGeoHierarchy =
      BangladeshGeoData.officialGeoHierarchy;

  static bool _hasLoadedFromCache = false;

  /// Get current administrative hierarchy (Divisions -> Districts -> Upazilas/Thanas)
  static Map<String, Map<String, List<String>>> getHierarchy() {
    if (!_hasLoadedFromCache) {
      _loadFromLocalCache();
      _hasLoadedFromCache = true;
    }
    return _currentGeoHierarchy;
  }

  /// 1. Load from Hive local storage (Offline First, 0ms latency)
  static void _loadFromLocalCache() {
    try {
      final cached = HiveService.getCachedGeoHierarchy();
      if (cached != null && cached.isNotEmpty) {
        final parsed = _convertDynamicMap(cached);
        if (parsed.isNotEmpty) {
          _currentGeoHierarchy = parsed;
          debugPrint('GeoService: Loaded from local Hive cache.');
        }
      }
    } catch (e) {
      debugPrint('GeoService cache load error: $e');
    }
  }

  /// 2. Asynchronously sync with Remote Server / API / Firestore
  /// If remote server is down, unreachable or times out, locally cached data remains completely safe!
  static Future<void> syncWithRemoteServer({VoidCallback? onUpdated}) async {
    bool updated = false;

    // A. Check Firestore 'settings/locations' if custom overrides exist
    try {
      if (Firebase.apps.isNotEmpty) {
        final doc = await FirebaseFirestore.instance
            .collection('settings')
            .doc('locations')
            .get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final parsed = _convertDynamicMap(data);
          if (parsed.isNotEmpty) {
            _currentGeoHierarchy = parsed;
            await HiveService.saveGeoHierarchy(data);
            updated = true;
            debugPrint('GeoService: Synced from Firestore settings/locations.');
          }
        }
      }
    } catch (e) {
      debugPrint('GeoService Firestore sync skipped: $e');
    }

    // B. Check open government mirror API (BD Geo Data)
    if (!updated) {
      try {
        final client = GetConnect(timeout: const Duration(seconds: 4));
        // Open data mirror for Bangladesh administrative units
        final response = await client.get(
          'https://raw.githubusercontent.com/nuhil/bangladesh-geojson/master/bangladesh-upazila-hierarchy.json',
        );

        if (response.isOk && response.body is Map) {
          final rawMap = Map<String, dynamic>.from(response.body);
          final parsed = _convertDynamicMap(rawMap);
          if (parsed.isNotEmpty) {
            _currentGeoHierarchy = parsed;
            await HiveService.saveGeoHierarchy(rawMap);
            updated = true;
            debugPrint('GeoService: Synced from remote open geo API.');
          }
        }
      } catch (e) {
        debugPrint(
          'GeoService remote server unreachable (using local cache): $e',
        );
      }
    }

    // Always ensure local cache has the latest hierarchy stored for future offline runs
    if (!updated) {
      final cached = HiveService.getCachedGeoHierarchy();
      if (cached == null || cached.isEmpty) {
        // Save official built-in dataset to Hive so it persists locally
        final mapToSave = _convertHierarchyToDynamic(_currentGeoHierarchy);
        await HiveService.saveGeoHierarchy(mapToSave);
      }
    }

    if (updated && onUpdated != null) {
      onUpdated();
    }
  }

  static Map<String, Map<String, List<String>>> _convertDynamicMap(
    Map<String, dynamic> raw,
  ) {
    final Map<String, Map<String, List<String>>> result = {};
    for (var divEntry in raw.entries) {
      final divName = divEntry.key.trim();
      if (divEntry.value is Map) {
        final Map<String, List<String>> districtMap = {};
        final rawDistricts = Map<String, dynamic>.from(divEntry.value as Map);
        for (var distEntry in rawDistricts.entries) {
          final distName = distEntry.key.trim();
          if (distEntry.value is List) {
            final upazilaList = (distEntry.value as List)
                .map((e) => e.toString().trim())
                .where((s) => s.isNotEmpty)
                .toList();
            if (upazilaList.isNotEmpty) {
              districtMap[distName] = upazilaList;
            }
          }
        }
        if (districtMap.isNotEmpty) {
          result[divName] = districtMap;
        }
      }
    }
    return result;
  }

  static Map<String, dynamic> _convertHierarchyToDynamic(
    Map<String, Map<String, List<String>>> hierarchy,
  ) {
    final Map<String, dynamic> output = {};
    for (var divEntry in hierarchy.entries) {
      final Map<String, dynamic> distMap = {};
      for (var distEntry in divEntry.value.entries) {
        distMap[distEntry.key] = distEntry.value;
      }
      output[divEntry.key] = distMap;
    }
    return output;
  }
}
