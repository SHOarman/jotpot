import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver_model.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static FirebaseFirestore get db => _db;

  /// Fetch active drivers from Firestore (excluding expired ones)
  static Stream<List<DriverModel>> streamActiveDrivers({
    String? division,
    String? district,
    String? upazila,
    String? vehicleType,
  }) {
    Query query = _db.collection('drivers').where('isActive', isEqualTo: true);

    if (division != null && division.isNotEmpty) {
      query = query.where('division', isEqualTo: division);
    }
    if (district != null && district.isNotEmpty) {
      query = query.where('district', isEqualTo: district);
    }
    if (upazila != null && upazila.isNotEmpty) {
      query = query.where('upazila', isEqualTo: upazila);
    }
    if (vehicleType != null && vehicleType.isNotEmpty) {
      query = query.where('vehicleType', isEqualTo: vehicleType);
    }

    return query.limit(50).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return DriverModel.fromMap(data, id: doc.id);
          })
          .toList();
    });
  }

  /// Register a new driver, send pending payment, and notify admin
  static Future<void> registerDriver({
    required String name,
    required String phone,
    required String vehicleType,
    String vehicleModel = '',
    String vehicleRegNumber = '',
    required String division,
    required String district,
    required String upazila,
    required String union,
    required String ward,
    String transactionId = '',
    int durationDays = 30,
    num amount = 0,
    bool isCovered = false,
    bool isAirAmbulance = false,
    bool isSelfDriving = false,
  }) async {
    final cleanPhone = phone.trim();
    // 1. Check duplicate phone
    final existing = await _db
        .collection('drivers')
        .where('phone', isEqualTo: cleanPhone)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('এই ফোন নাম্বারে ইতিমধ্যে রেজিস্ট্রেশন রয়েছে!');
    }

    // 2. Add to drivers collection (isActive: false until admin approves)
    final driverRef = await _db.collection('drivers').add({
      'name': name.trim(),
      'phone': cleanPhone,
      'vehicleType': vehicleType,
      'vehicleModel': vehicleModel.trim(),
      'vehicleRegNumber': vehicleRegNumber.trim(),
      'division': division,
      'district': district,
      'upazila': upazila,
      'union': union.trim(),
      'ward': ward.trim(),
      'isCovered': isCovered,
      'isAirAmbulance': isAirAmbulance,
      'isSelfDriving': isSelfDriving,
      'isActive': false,
      'expiryDate': DateTime.now().add(Duration(days: durationDays)),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 3. Add to payments collection if transaction provided or pending
    if (transactionId.trim().isNotEmpty || amount > 0) {
      await _db.collection('payments').add({
        'driverId': driverRef.id,
        'driverName': name.trim(),
        'driverPhone': cleanPhone,
        'amount': amount,
        'durationDays': durationDays,
        'transactionId': transactionId.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // 4. Send notification for Admin Dashboard
    await _db.collection('notifications').add({
      'type': 'registration',
      'driverId': driverRef.id,
      'driverName': name.trim(),
      'driverPhone': cleanPhone,
      'message': 'নতুন ড্রাইভার নিবন্ধন: ${name.trim()} ($cleanPhone)',
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': [],
    });
  }

  /// Submit driver license renewal request
  static Future<void> submitRenewal({
    required String driverId,
    required String driverName,
    required String driverPhone,
    required String transactionId,
    required int durationDays,
    required num amount,
  }) async {
    // 1. Create payment request
    await _db.collection('payments').add({
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'amount': amount,
      'durationDays': durationDays,
      'transactionId': transactionId.trim(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Send renewal notification to admin
    await _db.collection('notifications').add({
      'type': 'renewal',
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'message': 'লাইসেন্স রিনিউ রিকোয়েস্ট: $driverName ($driverPhone)',
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': [],
    });
  }

  /// Track phone call button click for Admin Dashboard analytics
  static Future<void> trackCallClick(
    String driverId,
    String driverName,
    String vehicleType,
  ) async {
    try {
      final nowStr = DateTime.now().toIso8601String().split('T')[0];
      await _db.collection('analytics_calls').add({
        'driverId': driverId,
        'driverName': driverName,
        'vehicleType': vehicleType,
        'date': nowStr,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Non-blocking analytics
    }
  }

  /// Listen to global settings (live banner, notice, registration status)
  static Stream<DocumentSnapshot<Map<String, dynamic>>> listenGlobalSettings() {
    return _db.collection('settings').doc('global').snapshots();
  }
}
