class VehicleTypeModel {
  final String id;
  final String name;
  final String bnName;
  final num monthlyFee;
  final num discountValue;
  final String discountType; // 'percentage' or 'amount'

  VehicleTypeModel({
    required this.id,
    required this.name,
    this.bnName = '',
    this.monthlyFee = 0,
    this.discountValue = 0,
    this.discountType = 'percentage',
  });

  factory VehicleTypeModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return VehicleTypeModel(
      id: id ?? (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      bnName: (map['bnName'] ?? '').toString(),
      monthlyFee: (map['monthlyFee'] as num?) ?? 0,
      discountValue: (map['discountValue'] as num?) ?? 0,
      discountType: (map['discountType'] ?? 'percentage').toString(),
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
    };
  }
}
