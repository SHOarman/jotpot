import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../data/bangladesh_unions_data.dart';

/// Loads union overrides from Firestore and falls back to the bundled dataset.
class UnionApiService {
  static const _settingsCollection = 'settings';
  static const _unionsDocument = 'unions';

  static List<String> _localUnions(String upazilaName, String districtBn) {
    final local = BangladeshUnionsData.getUnions(upazilaName);
    if (local.isNotEmpty) return local;
    return BangladeshUnionsData.getUnions('$districtBn $upazilaName');
  }

  /// Emits Firestore changes as they arrive. Bundled data remains the fallback
  /// when the document has no entry for this upazila or Firestore is unavailable.
  static Stream<List<String>> watchUnions({
    required String divisionBn,
    required String districtBn,
    required String upazilaName,
  }) {
    final fallback = _localUnions(upazilaName, districtBn);
    if (Firebase.apps.isEmpty) return Stream.value(fallback);

    return FirebaseFirestore.instance
        .collection(_settingsCollection)
        .doc(_unionsDocument)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (data == null) return fallback;
      final fromFirestore = _findUpazilaUnions(data, upazilaName);
      return fromFirestore.isNotEmpty ? fromFirestore : fallback;
    });
  }

  static Future<List<String>> getUnions({
    required String divisionBn,
    required String districtBn,
    required String upazilaName,
  }) async {
    final fallback = _localUnions(upazilaName, districtBn);
    if (Firebase.apps.isEmpty) return fallback;

    try {
      final doc = await FirebaseFirestore.instance
          .collection(_settingsCollection)
          .doc(_unionsDocument)
          .get();
      final data = doc.data();
      if (data == null) return fallback;
      final fromFirestore = _findUpazilaUnions(data, upazilaName);
      return fromFirestore.isNotEmpty ? fromFirestore : fallback;
    } catch (_) {
      return fallback;
    }
  }

  static List<String> _findUpazilaUnions(
    Map<String, dynamic> data,
    String upazilaName,
  ) {
    final target = _normalize(upazilaName);
    if (target.isEmpty) return const [];

    // Accept the common document shapes: {Upazila: [...]},
    // {unions: {Upazila: [...]}}, and lists of {upazila, name} records.
    for (final root in [data, data['unions'], data['data']]) {
      if (root is Map) {
        for (final entry in root.entries) {
          if (_normalize(entry.key.toString()) == target) {
            final names = _namesFromValue(entry.value);
            if (names.isNotEmpty) return names;
          }
        }
      } else if (root is List) {
        // Some admin schemas keep one flat union-name list on the document.
        // Use it only when entries are plain strings; record lists below are
        // scoped to an upazila to avoid mixing their names across areas.
        if (root.isNotEmpty && root.every((item) => item is String)) {
          final names = _namesFromValue(root);
          if (names.isNotEmpty) return names;
        }
        final matchingRecords = root.where((item) {
          if (item is! Map) return false;
          final map = Map<String, dynamic>.from(item);
          final upazila = map['upazila'] ?? map['upazilaName'] ?? map['thana'];
          return upazila != null && _normalize(upazila.toString()) == target;
        }).toList();
        final names = matchingRecords
            .map((item) => _recordName(Map<String, dynamic>.from(item as Map)))
            .whereType<String>()
            .toList();
        if (names.isNotEmpty) return names;
      }
    }

    return const [];
  }

  static List<String> _namesFromValue(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item is Map
              ? _recordName(Map<String, dynamic>.from(item))
              : item.toString())
          .whereType<String>()
          .map((name) => name.trim())
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList();
    }
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      for (final key in ['unions', 'unionList', 'items', 'list']) {
        if (map[key] is List) return _namesFromValue(map[key]);
      }
    }
    return const [];
  }

  static String? _recordName(Map<String, dynamic> record) {
    for (final key in ['name', 'union', 'unionName', 'nameBn', 'bnName']) {
      final value = record[key]?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  static String _normalize(String value) =>
      BangladeshUnionsData.normalizeBn(value.trim()).toLowerCase();

  static List<String> getUnionsSync(String upazilaName) {
    return BangladeshUnionsData.getUnions(upazilaName);
  }
}
