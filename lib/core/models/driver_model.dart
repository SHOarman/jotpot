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
  final String lastBkashNumber;
  final bool isCovered;
  final bool isAirAmbulance;
  final bool isSelfDriving;
  final String seatingCapacity;
  final String vehicleLength;
  final String vehicleCapacity;

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
    this.lastBkashNumber = '',
    this.isCovered = false,
    this.isAirAmbulance = false,
    this.isSelfDriving = false,
    this.seatingCapacity = '',
    this.vehicleLength = '',
    this.vehicleCapacity = '',
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
      'seatingCapacity': seatingCapacity,
      'vehicleLength': vehicleLength,
      'vehicleCapacity': vehicleCapacity,
      'isCovered': isCovered,
      'isAirAmbulance': isAirAmbulance,
      'isSelfDriving': isSelfDriving,
      'vehicleModel': vehicleModel,
      'vehicleRegNumber': vehicleRegNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'isActive': isActive,
      'autoPay': autoPay,
      'lastBkashNumber': lastBkashNumber,
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

    String vehicleModel = (map['vehicleModel'] ?? '').toString();
    String vehicleRegNumber = (map['vehicleRegNumber'] ?? '').toString();

    String details = (map['details'] ?? '').toString();
    if (vehicleModel.isEmpty && details.isNotEmpty) {
      final match = RegExp(r'(?:মডেল|Model):\s*([^|]+)').firstMatch(details);
      if (match != null) {
        vehicleModel = match.group(1)?.trim() ?? '';
      }
    }
    if (vehicleRegNumber.isEmpty && details.isNotEmpty) {
      final match = RegExp(r'(?:রেজিস্ট্রেশন|Registration|Reg):\s*([^|]+)').firstMatch(details);
      if (match != null) {
        vehicleRegNumber = match.group(1)?.trim() ?? '';
      }
    }

    if (details.isEmpty) {
      details = [
        if (vehicleModel.isNotEmpty) 'মডেল: $vehicleModel',
        if (vehicleRegNumber.isNotEmpty) 'রেজিস্ট্রেশন: $vehicleRegNumber',
      ].join(' | ');
    }

    final rawSeat =
        map['seatCount'] ?? map['seatingCapacity'] ?? map['capacity'];
    int? parsedSeat;
    if (rawSeat != null) {
      if (rawSeat is int) {
        parsedSeat = rawSeat;
      } else {
        String s = rawSeat.toString();
        const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
        for (int i = 0; i < 10; i++) {
          s = s.replaceAll(bn[i], '$i');
        }
        final match = RegExp(r'\d+').firstMatch(s);
        if (match != null) {
          parsedSeat = int.tryParse(match.group(0)!);
        }
      }
    }

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
      seatCount: parsedSeat,
      vehicleModel: vehicleModel,
      vehicleRegNumber: vehicleRegNumber,
      expiryDate: parsedExpiry,
      isActive: map['isActive'] == null ? true : map['isActive'] == true,
      autoPay: map['autoPay'] == true,
      lastBkashNumber:
          (map['lastBkashNumber'] ?? map['bkashNumber'] ?? '').toString(),
      isCovered: map['isCovered'] == true,
      isAirAmbulance: map['isAirAmbulance'] == true,
      isSelfDriving: map['isSelfDriving'] == true,
      seatingCapacity: (map['seatingCapacity'] ?? '').toString(),
      vehicleLength: (map['vehicleLength'] ?? '').toString(),
      vehicleCapacity: (map['vehicleCapacity'] ?? '').toString(),
    );
  }

  String getLocalizedDetails({required bool isBn}) {
    final modelLabel = isBn ? 'মডেল' : 'Model';
    final regLabel = isBn ? 'রেজিস্ট্রেশন' : 'Registration';
    final modelVal = vehicleModel.trim();
    final regVal = vehicleRegNumber.trim();
    if (modelVal.isNotEmpty || regVal.isNotEmpty) {
      final parts = <String>[];
      if (modelVal.isNotEmpty) {
        parts.add('$modelLabel: $modelVal');
      }
      if (regVal.isNotEmpty) {
        parts.add('$regLabel: $regVal');
      }
      return parts.join(' | ');
    }
    if (details.isNotEmpty) {
      if (isBn) {
        return details
            .replaceAll(RegExp(r'\bModel\s*:', caseSensitive: false), 'মডেল:')
            .replaceAll(RegExp(r'\bRegistration\s*:', caseSensitive: false), 'রেজিস্ট্রেশন:')
            .replaceAll(RegExp(r'\bReg\s*:', caseSensitive: false), 'রেজিস্ট্রেশন:');
      } else {
        return details
            .replaceAll(RegExp(r'মডেল\s*:'), 'Model:')
            .replaceAll(RegExp(r'রেজিস্ট্রেশন\s*:'), 'Registration:');
      }
    }
    return '';
  }
}

