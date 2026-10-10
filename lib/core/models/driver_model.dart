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

  factory DriverModel.fromMap(Map<dynamic, dynamic> map) {
    return DriverModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      vehicleType: map['vehicleType'] ?? 'Car',
      division: map['division'] ?? '',
      district: map['district'] ?? '',
      upazila: map['upazila'] ?? '',
      union: map['union'] ?? '',
      ward: map['ward'] ?? '',
      address: map['address'] ?? '',
      details: map['details'] ?? '',
      seatCount: map['seatCount'] != null
          ? int.tryParse(map['seatCount'].toString())
          : null,
    );
  }
}

