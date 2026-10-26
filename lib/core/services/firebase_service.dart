import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import '../models/driver_model.dart';

class FirebaseService {
  static FirebaseFirestore? _cachedDb;

  static FirebaseFirestore get db {
    _cachedDb ??= FirebaseFirestore.instance;
    return _cachedDb!;
  }

  static FirebaseFirestore get _db => db;

  /// Fetch active drivers from Firestore (excluding expired ones)
  static Stream<List<DriverModel>> streamActiveDrivers({
    String? division,
    String? district,
    String? upazila,
    String? vehicleType,
  }) {
    if (Firebase.apps.isEmpty) {
      return Stream.value([]);
    }
    Query query = db.collection('drivers').where('isActive', isEqualTo: true);

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
  /// Search driver in Firestore by phone number
  static Future<DriverModel?> searchDriverByPhone(String phone) async {
    final cleanPhone = phone.trim();
    if (cleanPhone.isEmpty) return null;

    try {
      // 1. Direct match
      var snap = await _db
          .collection('drivers')
          .where('phone', isEqualTo: cleanPhone)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        final doc = snap.docs.first;
        return DriverModel.fromMap(doc.data(), id: doc.id);
      }

      // 2. Fallback check with/without leading 0
      String altPhone = cleanPhone;
      if (cleanPhone.startsWith('0')) {
        altPhone = cleanPhone.substring(1);
      } else {
        altPhone = '0$cleanPhone';
      }

      snap = await _db
          .collection('drivers')
          .where('phone', isEqualTo: altPhone)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        final doc = snap.docs.first;
        return DriverModel.fromMap(doc.data(), id: doc.id);
      }
    } catch (e) {
      // ignore: avoid_print
      print('searchDriverByPhone error: $e');
    }
    return null;
  }

  /// Fetch all vehicle types from Firestore
  static Future<List<Map<String, dynamic>>> fetchVehicleTypes() async {
    try {
      final snap = await _db.collection('vehicleTypes').get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (_) {
      return [];
    }
  }

  /// Stream vehicle types from Firestore
  static Stream<List<Map<String, dynamic>>> streamVehicleTypes() {
    if (Firebase.apps.isEmpty) {
      return Stream.value([]);
    }
    return _db.collection('vehicleTypes').snapshots().map((snap) {
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    });
  }

  /// Calculate renewal amount with vehicle discount & package duration discount
  static int calculateRenewalAmount({
    required num monthlyFee,
    required int durationDays, // 30, 90, 180, 365
    num vehicleDiscount = 0,
    String discountType = 'percentage',
    num durationDiscount = 0, // discount3Months, discount6Months, discount1Year
  }) {
    double rawBase = (monthlyFee / 30) * durationDays;
    double discountedBase = rawBase;
    // ভেহিক্যাল ডিসকাউন্ট
    if (vehicleDiscount > 0) {
      if (discountType == 'percentage') {
        discountedBase = discountedBase * (1 - vehicleDiscount / 100);
      } else {
        discountedBase = (discountedBase - (vehicleDiscount / 30 * durationDays))
            .clamp(0.0, double.infinity);
      }
    }
    // মেয়াদের ডিসকাউন্ট (৩ মাস, ৬ মাস, ১ বছর)
    double finalAmount = discountedBase * (1 - durationDiscount / 100);
    return finalAmount.round();
  }

  /// Submit driver license renewal request to Admin Dashboard
  static Future<void> submitRenewalToAdmin({
    required String driverId,
    required String driverName,
    required String driverPhone,
    required String transactionId,
    required int durationDays,
    required num amount,
    String bkashNumber = '',
    bool autoPay = false,
  }) async {
    final cleanBkash = bkashNumber.trim();

    // 1. Payments কালেকশনে জমা হবে (অ্যাডমিন প্যানেলের Subscription Payments ট্যাবে দেখাবে)
    await _db.collection('payments').add({
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'bkashNumber': cleanBkash.isNotEmpty ? cleanBkash : driverPhone,
      'paymentMethod': 'bKash',
      'amount': amount,
      'durationDays': durationDays,
      'transactionId': transactionId.trim(),
      'status': 'pending', // অ্যাডমিন পেন্ডিং হিসেবে দেখবে
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. ড্রাইভার ডকুমেন্টে লাস্ট বিকাশ নম্বর ও অটো পে আপডেট
    final Map<String, dynamic> driverUpdates = {
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (cleanBkash.isNotEmpty) {
      driverUpdates['lastBkashNumber'] = cleanBkash;
    }
    if (autoPay) {
      driverUpdates['autoPay'] = true;
    }
    try {
      await _db.collection('drivers').doc(driverId).update(driverUpdates);
    } catch (_) {}

    // 3. Admin Notification কালেকশনে পাঠানো হবে (অ্যাডমিনের বেল আইকনে লাল ব্যাজ শো করবে)
    final bkashNotice =
        cleanBkash.isNotEmpty ? ' | বিকাশ: $cleanBkash' : '';
    await _db.collection('notifications').add({
      'type': 'renewal',
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'bkashNumber': cleanBkash,
      'amount': amount,
      'transactionId': transactionId.trim(),
      'message':
          'লাইসেন্স রিনিউ রিকোয়েস্ট: $driverName ($driverPhone)$bkashNotice - Trx: $transactionId',
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': [],
    });
  }

  /// Alias for backward compatibility
  static Future<void> submitRenewal({
    required String driverId,
    required String driverName,
    required String driverPhone,
    required String transactionId,
    required int durationDays,
    required num amount,
    String bkashNumber = '',
    bool autoPay = false,
  }) =>
      submitRenewalToAdmin(
        driverId: driverId,
        driverName: driverName,
        driverPhone: driverPhone,
        transactionId: transactionId,
        durationDays: durationDays,
        amount: amount,
        bkashNumber: bkashNumber,
        autoPay: autoPay,
      );

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
    if (Firebase.apps.isEmpty) {
      return const Stream.empty();
    }
    return _db.collection('settings').doc('global').snapshots();
  }
}
