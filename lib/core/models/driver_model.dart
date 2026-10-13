class DriverModel {
  final String id;
  final String name;
  final String phone;
  final String vehicleType;
  final String division;
  final String district;
  final String upazila;
  final String union;
  final String ward;
  final String address;
  final String details;
  final int? seatCount;

  DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicleType,
    required this.division,
    required this.district,
    required this.upazila,
    required this.union,
    required this.ward,
    required this.address,
    required this.details,
    this.seatCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'vehicleType': vehicleType,
      'division': division,
      'district': district,
      'upazila': upazila,
      'union': union,
      'ward': ward,
      'address': address,
      'details': details,
      'seatCount': seatCount,
    };
  }

  factory DriverModel.fromMap(Map<dynamic, dynamic> map, {String? id}) {
    final union = (map['union'] ?? '').toString();
    final upazila = (map['upazila'] ?? '').toString();
    final district = (map['district'] ?? '').toString();
    final division = (map['division'] ?? '').toString();
    final ward = (map['ward'] ?? '').toString();

    String address = (map['address'] ?? '').toString();
    if (address.isEmpty) {
      address = [
        if (union.isNotEmpty) union,
        if (upazila.isNotEmpty) upazila,
        if (district.isNotEmpty) district,
        if (division.isNotEmpty) division,
      ].join(', ');
    }

    String details = (map['details'] ?? '').toString();
    if (details.isEmpty) {
      final model = (map['vehicleModel'] ?? '').toString();
      final reg = (map['vehicleRegNumber'] ?? '').toString();
      details = [
        if (model.isNotEmpty) 'মডেল: $model',
        if (reg.isNotEmpty) 'রেজিস্ট্রেশন: $reg',
      ].join(' | ');
    }

    final rawSeat =
        map['seatCount'] ?? map['seatingCapacity'] ?? map['capacity'];

    return DriverModel(
      id: id ?? (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      vehicleType: (map['vehicleType'] ?? 'Car').toString(),
      division: division,
      district: district,
      upazila: upazila,
      union: union,
      ward: ward,
      address: address,
      details: details,
      seatCount: rawSeat != null ? int.tryParse(rawSeat.toString()) : null,
    );
  }
}

