class VehicleTypeModel {
  final String id;
  final String name;
  final String bnName;
  final num monthlyFee;
  final num discountValue;
  final String discountType; // 'percentage' or 'amount'
  final bool isVisible;
  final bool isActive;

  VehicleTypeModel({
    required this.id,
    required this.name,
    this.bnName = '',
    this.monthlyFee = 0,
    this.discountValue = 0,
    this.discountType = 'percentage',
    this.isVisible = true,
    this.isActive = true,
  });

  static num _parseNum(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val;
    return num.tryParse(val.toString().trim()) ?? 0;
  }

  factory VehicleTypeModel.fromMap(Map<String, dynamic> map, {String? id}) {
    final status = (map['status'] ?? '').toString().toLowerCase().trim();
    final bool rawVisible = map['isVisible'] != false && status != 'hidden';
    final bool rawActive = map['isActive'] != false && rawVisible;

    return VehicleTypeModel(
      id: id ?? (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString().trim(),
      bnName: (map['bnName'] ?? '').toString().trim(),
      monthlyFee: _parseNum(map['monthlyFee']),
      discountValue: _parseNum(map['discountValue']),
      discountType: (map['discountType'] ?? 'percentage').toString(),
      isVisible: rawVisible,
      isActive: rawActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bnName': bnName,
      'monthlyFee': monthlyFee,
      'discountValue': discountValue,
      'discountType': discountType,
      'isVisible': isVisible,
      'isActive': isActive,
    };
  }
}
