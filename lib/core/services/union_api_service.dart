import '../data/bangladesh_unions_data.dart';

/// Service providing instantaneous (0ms) offline Bangladesh union/municipality data.
/// Preloaded with 4,540+ official Union Parishads mapped across all 494 Upazilas.
class UnionApiService {
  static Future<List<String>> getUnions({
    required String divisionBn,
    required String districtBn,
    required String upazilaName,
  }) async {
    final localUnions = BangladeshUnionsData.getUnions(upazilaName);
    if (localUnions.isNotEmpty) return localUnions;
    final fallback = BangladeshUnionsData.getUnions('$districtBn $upazilaName');
    if (fallback.isNotEmpty) return fallback;
    return localUnions;
  }

  static List<String> getUnionsSync(String upazilaName) {
    return BangladeshUnionsData.getUnions(upazilaName);
  }
}
