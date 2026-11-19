class LocationModel {
  final String id;
  final String name;
  final String bnName;
  final String enName;
  final String level;
  final String? parentDivision;
  final String? parentDistrict;
  final String? parentUpazila;
  final String? parentRef;
  final String? parentId;
  final String? division;
  final String? district;
  final String? upazila;
  final String? union;

  LocationModel({
    required this.id,
    required this.name,
    this.bnName = '',
    this.enName = '',
    required this.level,
    this.parentDivision,
    this.parentDistrict,
    this.parentUpazila,
    this.parentRef,
    this.parentId,
    this.division,
    this.district,
    this.upazila,
    this.union,
  });

  factory LocationModel.fromFirestore(Map<String, dynamic> data, String id) {
    return LocationModel(
      id: id,
      name: (data['name'] ?? '').toString().trim(),
      bnName: (data['bnName'] ?? data['nameBn'] ?? '').toString().trim(),
      enName: (data['enName'] ?? data['nameEn'] ?? '').toString().trim(),
      level: (data['level'] ?? '').toString().trim().toLowerCase(),
      parentDivision: data['parentDivision']?.toString().trim(),
      parentDistrict: data['parentDistrict']?.toString().trim(),
      parentUpazila: (data['parentUpazila'] ?? data['parentId'])
          ?.toString()
          .trim(),
      parentRef: data['parentRef']?.toString().trim(),
      parentId: (data['parentId'] ?? data['parentUpazila'])?.toString().trim(),
      division: data['division']?.toString().trim(),
      district: data['district']?.toString().trim(),
      upazila: data['upazila']?.toString().trim(),
      union: data['union']?.toString().trim(),
    );
  }

  String get effectiveDivision =>
      (division != null && division!.trim().isNotEmpty)
      ? division!.trim()
      : (parentDivision ?? '').trim();

  String get effectiveDistrict =>
      (district != null && district!.trim().isNotEmpty)
      ? district!.trim()
      : (parentDistrict ?? '').trim();

  String get effectiveUpazila => (upazila != null && upazila!.trim().isNotEmpty)
      ? upazila!.trim()
      : (parentUpazila ?? parentId ?? '').trim();

  String displayName(bool isBengali) {
    if (isBengali) {
      if (bnName.isNotEmpty) return bnName;
      if (name.isNotEmpty) return name;
      return enName;
    } else {
      if (enName.isNotEmpty) return enName;
      if (name.isNotEmpty) return name;
      return bnName;
    }
  }

  /// Parses parentRef string in the format:
  /// `<type>:<encodedDivision>:<encodedDistrict>:<encodedParent>`
  static Map<String, String>? parseParentRef(String? ref) {
    if (ref == null) return null;
    final parts = ref.split(':');
    if (parts.length >= 4) {
      try {
        return {
          'type': parts[0].trim(),
          'division': Uri.decodeComponent(parts[1]).trim(),
          'district': Uri.decodeComponent(parts[2]).trim(),
          'parent': Uri.decodeComponent(parts.sublist(3).join(':')).trim(),
        };
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
