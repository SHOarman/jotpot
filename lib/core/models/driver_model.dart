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
  final String vehicleModel;
  final String vehicleRegNumber;
  final DateTime? expiryDate;
  final bool isActive;
  final bool autoPay;

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
    this.vehicleModel = '',
    this.vehicleRegNumber = '',
    this.expiryDate,
    this.isActive = true,
    this.autoPay = false,
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
      'vehicleModel': vehicleModel,
      'vehicleRegNumber': vehicleRegNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'isActive': isActive,
      'autoPay': autoPay,
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

    final vehicleModel = (map['vehicleModel'] ?? '').toString();
    final vehicleRegNumber = (map['vehicleRegNumber'] ?? '').toString();

    String details = (map['details'] ?? '').toString();
    if (details.isEmpty) {
      details = [
        if (vehicleModel.isNotEmpty) 'মডেল: $vehicleModel',
        if (vehicleRegNumber.isNotEmpty) 'রেজিস্ট্রেশন: $vehicleRegNumber',
      ].join(' | ');
    }

    final rawSeat =
        map['seatCount'] ?? map['seatingCapacity'] ?? map['capacity'];

    DateTime? parsedExpiry;
    final rawExpiry = map['expiryDate'];
    if (rawExpiry != null) {
      if (rawExpiry is DateTime) {
        parsedExpiry = rawExpiry;
      } else if (rawExpiry.runtimeType.toString().contains('Timestamp')) {
        try {
          parsedExpiry = (rawExpiry as dynamic).toDate();
        } catch (_) {}
      } else if (rawExpiry is String) {
        parsedExpiry = DateTime.tryParse(rawExpiry);
      } else if (rawExpiry is int) {
        parsedExpiry = DateTime.fromMillisecondsSinceEpoch(rawExpiry);
      }
    }

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
      vehicleModel: vehicleModel,
      vehicleRegNumber: vehicleRegNumber,
      expiryDate: parsedExpiry,
      isActive: map['isActive'] == null ? true : map['isActive'] == true,
      autoPay: map['autoPay'] == true,
    );
  }
}

