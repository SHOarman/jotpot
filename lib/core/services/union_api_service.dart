import 'package:flutter/foundation.dart';
import 'package:get/get_connect/connect.dart';

/// Service to fetch Bangladesh union/municipality data from the BD open API.
/// Uses a cascading ID resolution: division name → district name → upazila name → unions.
/// All results are cached in memory to avoid redundant API calls.
class UnionApiService {
  static const String _baseUrl = 'https://bdapis.pro.bd/geo/v2.0';

  // Cascading ID caches
  static final Map<String, int?> _divisionIdCache = {}; // bn_name → api_id
  static final Map<String, int?> _districtIdCache = {}; // "divId/bn_name" → api_id
  static final Map<String, int?> _upazilaIdCache = {}; // "distId/bn_name" → api_id

  // Final result cache: upazila_bn_name → list of union names (Bengali)
  static final Map<String, List<String>> _unionCache = {};

  static final GetConnect _client = GetConnect(
    timeout: const Duration(seconds: 10),
  );

  static Future<Response<dynamic>> _fetchJson(String path) async {
    return _client.get('$_baseUrl$path');
  }

  static String _normalizeName(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized
        .replaceAll(RegExp(r'[\s\-_/]+'), ' ')
        .replaceAll(RegExp(r'[^a-z0-9\u0980-\u09FF\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Fetch list of union/পৌরসভা names for the given upazila.
  /// Returns empty list on API failure (graceful degradation).
  static List<String> _localFallbackUnions({
    String? divisionBn,
    String? districtBn,
    String? upazilaName,
  }) {
    // Never use upazila names as union names. That produces incorrect filter
    // values when the remote union service is unavailable.
    return const [];
  }

  static Future<List<String>> getAllUnions() async {
    const cacheKey = '__all__';
    if (_unionCache.containsKey(cacheKey)) {
      return _unionCache[cacheKey]!;
    }

    try {
      final response = await _fetchJson('/unions');
      if (!response.isOk) {
        final fallback = _localFallbackUnions();
        _unionCache[cacheKey] = fallback;
        return fallback;
      }

      final unions = _parseNames(response.body);
      final unique = unions
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      _unionCache[cacheKey] = unique;
      return unique;
    } catch (e) {
      debugPrint('UnionApiService all-unions error: $e');
      final fallback = _localFallbackUnions();
      _unionCache[cacheKey] = fallback;
      return fallback;
    }
  }

  static Future<List<String>> getUnions({
    required String divisionBn,
    required String districtBn,
    required String upazilaName,
  }) async {
    final cacheKey = upazilaName.trim();
    if (_unionCache.containsKey(cacheKey)) {
      return _unionCache[cacheKey]!;
    }

    try {
      final divId = await _getDivisionId(divisionBn);
      if (divId == null) {
        final fallback = _localFallbackUnions(
          divisionBn: divisionBn,
          districtBn: districtBn,
          upazilaName: upazilaName,
        );
        _unionCache[cacheKey] = fallback;
        return fallback;
      }

      final distId = await _getDistrictId(divId, districtBn);
      if (distId == null) {
        final fallback = _localFallbackUnions(
          divisionBn: divisionBn,
          districtBn: districtBn,
          upazilaName: upazilaName,
        );
        _unionCache[cacheKey] = fallback;
        return fallback;
      }

      final upazilaId = await _getUpazilaId(distId, upazilaName);
      if (upazilaId == null) {
        final fallback = _localFallbackUnions(
          divisionBn: divisionBn,
          districtBn: districtBn,
          upazilaName: upazilaName,
        );
        _unionCache[cacheKey] = fallback;
        return fallback;
      }

      final response = await _fetchJson('/unions/$upazilaId');
      if (!response.isOk) {
        final fallback = _localFallbackUnions(
          divisionBn: divisionBn,
          districtBn: districtBn,
          upazilaName: upazilaName,
        );
        _unionCache[cacheKey] = fallback;
        return fallback;
      }

      final unions = _parseNames(response.body);
      final unique = unions
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      _unionCache[cacheKey] = unique;
      return unique;
    } catch (e) {
      debugPrint('UnionApiService error: $e');
      final fallback = _localFallbackUnions(
        divisionBn: divisionBn,
        districtBn: districtBn,
        upazilaName: upazilaName,
      );
      _unionCache[cacheKey] = fallback;
      return fallback;
    }
  }

  // ─── Private ID Resolvers ────────────────────────────────────────────────

  static Future<int?> _getDivisionId(String nameBn) async {
    final key = nameBn.trim();
    if (_divisionIdCache.containsKey(key)) return _divisionIdCache[key];
    try {
      final r = await _fetchJson('/divisions');
      if (!r.isOk) return null;
      final id = _findId(_parseItems(r.body), key);
      _divisionIdCache[key] = id;
      return id;
    } catch (_) {
      return null;
    }
  }

  static Future<int?> _getDistrictId(int divisionId, String nameBn) async {
    final key = '$divisionId/${nameBn.trim()}';
    if (_districtIdCache.containsKey(key)) return _districtIdCache[key];
    try {
      final r = await _fetchJson('/districts/$divisionId');
      if (!r.isOk) return null;
      final id = _findId(_parseItems(r.body), nameBn);
      _districtIdCache[key] = id;
      return id;
    } catch (_) {
      return null;
    }
  }

  static Future<int?> _getUpazilaId(int districtId, String nameBn) async {
    final key = '$districtId/${nameBn.trim()}';
    if (_upazilaIdCache.containsKey(key)) return _upazilaIdCache[key];
    try {
      final r = await _fetchJson('/upazilas/$districtId');
      if (!r.isOk) return null;
      final id = _findId(_parseItems(r.body), nameBn);
      _upazilaIdCache[key] = id;
      return id;
    } catch (_) {
      return null;
    }
  }

  // ─── Response Parsers ────────────────────────────────────────────────────

  static List<Map<String, dynamic>> _parseItems(dynamic body) {
    List? raw;
    if (body is List) {
      raw = body;
    } else if (body is Map) {
      raw = body['data'] as List? ??
          body['results'] as List? ??
          body['items'] as List?;
      if (raw == null) {
        for (final v in body.values) {
          if (v is List) {
            raw = v;
            break;
          }
        }
      }
    }
    if (raw == null) return [];
    return raw.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
  }

  /// Find the numeric API id of an item that matches the given Bengali name.
  static int? _findId(List<Map<String, dynamic>> items, String nameBn) {
    final cleanName = _normalizeName(nameBn);
    if (cleanName.isEmpty) return null;

    for (final item in items) {
      final itemNames = <String>{
        _normalizeName((item['name_bn'] ?? '').toString()),
        _normalizeName((item['bn_name'] ?? '').toString()),
        _normalizeName((item['name'] ?? '').toString()),
        _normalizeName((item['en_name'] ?? '').toString()),
      }..removeWhere((value) => value.isEmpty);

      for (final candidate in itemNames) {
        if (candidate == cleanName ||
            candidate.contains(cleanName) ||
            cleanName.contains(candidate)) {
          final id = item['id'];
          if (id is int) return id;
          if (id is String) return int.tryParse(id);
          if (id is double) return id.toInt();
        }
      }
    }
    return null;
  }

  /// Extract Bengali names from an API response body.
  static List<String> _parseNames(dynamic body) {
    return _parseItems(body)
        .map((item) =>
            item['name_bn']?.toString() ??
            item['bn_name']?.toString() ??
            item['name']?.toString() ??
            item['en_name']?.toString() ??
            '')
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  /// Clear all in-memory caches (useful for testing or language switch).
  static void clearCache() {
    _divisionIdCache.clear();
    _districtIdCache.clear();
    _upazilaIdCache.clear();
    _unionCache.clear();
  }
}
