import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../data/bangladesh_unions_data.dart';
import '../../utils/app_strings.dart';

/// Loads union overrides from Firestore and falls back to the bundled dataset.
class UnionApiService {
  static const _settingsCollection = 'settings';
  static const _unionsDocument = 'unions';

  static List<String> _localUnions(String upazilaName, String districtBn) {
    final local = BangladeshUnionsData.getUnions(upazilaName);
    if (local.isNotEmpty && !_isWardOnlyList(local)) return local;
    final distLocal = BangladeshUnionsData.getUnions('$districtBn $upazilaName');
    if (distLocal.isNotEmpty && !_isWardOnlyList(distLocal)) return distLocal;
    return const [];
  }

  static bool _isWardOnlyList(List<String> list) {
    if (list.isEmpty) return false;
    return list.every((item) {
      final lower = item.trim().toLowerCase();
      return lower.contains('ওয়ার্ড') || lower.contains('ward');
    });
  }

  /// Emits Firestore changes as they arrive. Bundled data remains the fallback
  /// when the document has no entry for this upazila or Firestore is unavailable.
  static Stream<List<String>> watchUnions({
    required String divisionBn,
    required String districtBn,
    required String upazilaName,
    bool isBengali = true,
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
      final fromFirestore = _findUpazilaUnions(data, upazilaName, isBengali: isBengali);
      return fromFirestore.isNotEmpty ? fromFirestore : fallback;
    });
  }

  static Future<List<String>> getUnions({
    required String divisionBn,
    required String districtBn,
    required String upazilaName,
    bool isBengali = true,
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
      final fromFirestore = _findUpazilaUnions(data, upazilaName, isBengali: isBengali);
      return fromFirestore.isNotEmpty ? fromFirestore : fallback;
    } catch (_) {
      return fallback;
    }
  }

  static String _stripSuffixes(String input) {
    return _normalize(input)
        .replaceAll(
            RegExp(r'\s*\(?(পৌরসভা|pourashava|municipality)\)?',
                caseSensitive: false),
            '')
        .replaceAll(
            RegExp(r'\s*\(?(সদর|sadar)\)?', caseSensitive: false), '')
        .replaceAll(
            RegExp(r'\s*\(?(মডেল|model)\)?', caseSensitive: false), '')
        .replaceAll(
            RegExp(r'\s*\(?(থানা|thana)\)?', caseSensitive: false), '')
        .trim();
  }

  static Set<String> _getTargetAliases(String upazilaName) {
    final targets = <String>{};
    final norm = _normalize(upazilaName);
    if (norm.isNotEmpty) targets.add(norm);

    final bn = _normalize(AppStrings.translateUpazilaStatic(upazilaName, true));
    if (bn.isNotEmpty) targets.add(bn);

    final en = _normalize(AppStrings.translateUpazilaStatic(upazilaName, false));
    if (en.isNotEmpty) targets.add(en);

    return targets;
  }

  static bool _isExactMatch(String entryKey, Set<String> targetAliases) {
    final normKey = _normalize(entryKey);
    if (normKey.isEmpty) return false;
    if (targetAliases.contains(normKey)) return true;

    final keyBn = _normalize(AppStrings.translateUpazilaStatic(entryKey, true));
    if (keyBn.isNotEmpty && targetAliases.contains(keyBn)) return true;

    final keyEn = _normalize(AppStrings.translateUpazilaStatic(entryKey, false));
    if (keyEn.isNotEmpty && targetAliases.contains(keyEn)) return true;

    return false;
  }

  static bool _isCleanSuffixMatch(String entryKey, Set<String> targetAliases) {
    final cleanKey = _stripSuffixes(entryKey);
    if (cleanKey.isEmpty) return false;

    for (final alias in targetAliases) {
      final cleanTarget = _stripSuffixes(alias);
      if (cleanTarget.isNotEmpty && cleanKey == cleanTarget) {
        return true;
      }
    }

    final keyBn =
        _stripSuffixes(AppStrings.translateUpazilaStatic(entryKey, true));
    if (keyBn.isNotEmpty) {
      for (final alias in targetAliases) {
        final cleanTarget = _stripSuffixes(alias);
        if (cleanTarget.isNotEmpty && keyBn == cleanTarget) {
          return true;
        }
      }
    }

    return false;
  }

  static bool _isSubstringMatch(String entryKey, Set<String> targetAliases) {
    final cleanKey = _stripSuffixes(entryKey);
    if (cleanKey.length < 3) return false;

    for (final alias in targetAliases) {
      final cleanTarget = _stripSuffixes(alias);
      if (cleanTarget.length >= 3) {
        if (cleanKey.contains(cleanTarget) || cleanTarget.contains(cleanKey)) {
          return true;
        }
      }
    }

    return false;
  }

  static List<String> _findUpazilaUnions(
    Map<String, dynamic> data,
    String upazilaName, {
    bool isBengali = true,
  }) {
    final target = _normalize(upazilaName);
    if (target.isEmpty) return const [];

    final targetAliases = _getTargetAliases(upazilaName);

    // Accept the common document shapes: {Upazila: [...]},
    // {unions: {Upazila: [...]}}, and lists of {upazila, name} records.
    for (final root in [data, data['unions'], data['data']]) {
      if (root is Map) {
        final entries = Map<String, dynamic>.from(root);

        // Pass 1: Exact target or bilingual alias match
        for (final entry in entries.entries) {
          if (_isExactMatch(entry.key.toString(), targetAliases)) {
            final names = _namesFromValue(entry.value, isBengali: isBengali);
            if (names.isNotEmpty) return names;
          }
        }

        // Pass 2: Clean suffix match (stripping 'পৌরসভা', 'সদর', etc.)
        for (final entry in entries.entries) {
          if (_isCleanSuffixMatch(entry.key.toString(), targetAliases)) {
            final names = _namesFromValue(entry.value, isBengali: isBengali);
            if (names.isNotEmpty) return names;
          }
        }

        // Pass 3: Substring match for compound names
        for (final entry in entries.entries) {
          if (_isSubstringMatch(entry.key.toString(), targetAliases)) {
            final names = _namesFromValue(entry.value, isBengali: isBengali);
            if (names.isNotEmpty) return names;
          }
        }
      } else if (root is List) {
        // Some admin schemas keep one flat union-name list on the document.
        if (root.isNotEmpty && root.every((item) => item is String)) {
          final names = _namesFromValue(root, isBengali: isBengali);
          if (names.isNotEmpty) return names;
        }
        final matchingRecords = root.where((item) {
          if (item is! Map) return false;
          final map = Map<String, dynamic>.from(item);
          final upazila = map['upazila'] ?? map['upazilaName'] ?? map['thana'];
          if (upazila == null) return false;
          final uStr = upazila.toString();
          return _isExactMatch(uStr, targetAliases) ||
              _isCleanSuffixMatch(uStr, targetAliases) ||
              _isSubstringMatch(uStr, targetAliases);
        }).toList();
        final names = matchingRecords
            .map((item) => _recordName(Map<String, dynamic>.from(item as Map), isBengali: isBengali))
            .whereType<String>()
            .toList();
        if (names.isNotEmpty) return names;
      }
    }

    return const [];
  }

  static List<String> _namesFromValue(dynamic value, {bool isBengali = true}) {
    if (value is List) {
      return value
          .map((item) => item is Map
              ? _recordName(Map<String, dynamic>.from(item), isBengali: isBengali)
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
        if (map[key] is List) return _namesFromValue(map[key], isBengali: isBengali);
      }
    }
    return const [];
  }

  static String? _recordName(Map<String, dynamic> record, {bool isBengali = true}) {
    if (isBengali) {
      for (final key in ['bnName', 'nameBn', 'name', 'union', 'unionName', 'enName', 'nameEn']) {
        final value = record[key]?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }
    } else {
      for (final key in ['enName', 'nameEn', 'name', 'union', 'unionName', 'bnName', 'nameBn']) {
        final value = record[key]?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }
    }
    return null;
  }

  static String _normalize(String value) =>
      BangladeshUnionsData.normalizeBn(value.trim()).toLowerCase();

  static List<String> getUnionsSync(String upazilaName) {
    return BangladeshUnionsData.getUnions(upazilaName);
  }
}
