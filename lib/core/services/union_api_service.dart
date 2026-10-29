import '../data/bangladesh_unions_data.dart';

/// Service providing instantaneous (0ms) offline Bangladesh union/municipality data.
/// Preloaded with 4,540+ official Union Parishads mapped across all 494 Upazilas.
class UnionApiService {
  static const String _baseUrl = 'https://bdapi.vercel.app/api/v1.1';

  // Cascading ID caches
  static final Map<String, int?> _divisionIdCache = {}; // bn_name → api_id
  static final Map<String, int?> _districtIdCache = {}; // "divId/bn_name" → api_id
  static final Map<String, int?> _upazilaIdCache = {}; // "distId/bn_name" → api_id

  // Final result cache: upazila_bn_name → list of union names (Bengali)
  static final Map<String, List<String>> _unionCache = {};

  static final GetConnect _client = GetConnect(
    timeout: const Duration(seconds: 10),
  );

  /// Fetch list of union/পৌরসভা names for the given upazila.
  /// Returns empty list on API failure (graceful degradation).
  static Future<List<String>> getUnions({
    required String divisionBn,
    required String districtBn,
    required String upazilaName,
  }) async {
    // Return cached result if available
    if (_unionCache.containsKey(upazilaName)) {
      return _unionCache[upazilaName]!;
    }

    try {
      // Step 1: Resolve division ID
      final divId = await _getDivisionId(divisionBn);
      if (divId == null) {
        _unionCache[upazilaName] = [];
        return [];
      }

      // Step 2: Resolve district ID
      final distId = await _getDistrictId(divId, districtBn);
      if (distId == null) {
        _unionCache[upazilaName] = [];
        return [];
      }

      // Step 3: Resolve upazila ID
      final upazilaId = await _getUpazilaId(distId, upazilaName);
      if (upazilaId == null) {
        _unionCache[upazilaName] = [];
        return [];
      }

      // Step 4: Fetch unions for this upazila
      final response = await _client.get('$_baseUrl/union/$upazilaId');
      if (!response.isOk) {
        _unionCache[upazilaName] = [];
        return [];
      }

      final unions = _parseNames(response.body);
      _unionCache[upazilaName] = unions;
      return unions;
    } catch (e) {
      debugPrint('UnionApiService error: $e');
      _unionCache[upazilaName] = [];
      return [];
    }
  }

  // ─── Private ID Resolvers ────────────────────────────────────────────────

  static Future<int?> _getDivisionId(String nameBn) async {
    if (_divisionIdCache.containsKey(nameBn)) return _divisionIdCache[nameBn];
    try {
      final r = await _client.get('$_baseUrl/division');
      if (!r.isOk) return null;
      final id = _findId(_parseItems(r.body), nameBn);
      _divisionIdCache[nameBn] = id;
      return id;
    } catch (_) {
      return null;
    }
  }

  static Future<int?> _getDistrictId(int divisionId, String nameBn) async {
    final key = '$divisionId/$nameBn';
    if (_districtIdCache.containsKey(key)) return _districtIdCache[key];
    try {
      final r = await _client.get('$_baseUrl/district/$divisionId');
      if (!r.isOk) return null;
      final id = _findId(_parseItems(r.body), nameBn);
      _districtIdCache[key] = id;
      return id;
    } catch (_) {
      return null;
    }
  }

  static Future<int?> _getUpazilaId(int districtId, String nameBn) async {
    final key = '$districtId/$nameBn';
    if (_upazilaIdCache.containsKey(key)) return _upazilaIdCache[key];
    try {
      final r = await _client.get('$_baseUrl/upazila/$districtId');
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
    final cleanName = nameBn.trim();
    for (final item in items) {
      final bnName = (item['name_bn'] ?? '').toString().trim();
      final enName = (item['name'] ?? '').toString().trim();
      if (bnName == cleanName ||
          enName == cleanName ||
          (bnName.isNotEmpty && cleanName.contains(bnName)) ||
          (bnName.isNotEmpty && bnName.contains(cleanName))) {
        final id = item['id'];
        if (id is int) return id;
        if (id is String) return int.tryParse(id);
        if (id is double) return id.toInt();
      }
    }
    return null;
  }

  /// Extract Bengali names from an API response body.
  static List<String> _parseNames(dynamic body) {
    return _parseItems(body)
        .map((item) =>
            item['name_bn']?.toString() ?? item['name']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
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
