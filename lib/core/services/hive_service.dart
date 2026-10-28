import 'package:hive_flutter/hive_flutter.dart';
import '../models/driver_model.dart';
import '../models/note_model.dart';

class HiveService {
  static const String _boxName = 'jotpot_drivers_box';
  static const String _paymentBoxName = 'jotpot_payment_prefs';
  static const String _geoBoxName = 'jotpot_geo_cache';
  static Box? _box;
  static Box? _paymentBox;
  static Box? _geoBox;

  /// Initialize Hive and open driver directory, payment, and geo cache boxes
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    _paymentBox = await Hive.openBox(_paymentBoxName);
    _geoBox = await Hive.openBox(_geoBoxName);
    
    // Clear any previous mock/dummy data so only real Firestore data exists
    await _box!.clear();
  }

  /// Save geo hierarchy map to local cache
  static Future<void> saveGeoHierarchy(Map<String, dynamic> data) async {
    try {
      _geoBox ??= await Hive.openBox(_geoBoxName);
      await _geoBox!.put('geo_hierarchy', data);
      await _geoBox!.put('geo_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (_) {}
  }

  /// Retrieve cached geo hierarchy map from local storage
  static Map<String, dynamic>? getCachedGeoHierarchy() {
    try {
      if (_geoBox == null) return null;
      final raw = _geoBox!.get('geo_hierarchy');
      if (raw is Map) {
        return Map<String, dynamic>.from(raw);
      }
    } catch (_) {}
    return null;
  }

  /// Save last used bKash number for driver/user
  static Future<void> saveLastBkashNumber({
    required String driverPhone,
    required String bkashNumber,
    String? driverId,
  }) async {
    _paymentBox ??= await Hive.openBox(_paymentBoxName);
    final cleanPhone = driverPhone.trim();
    final cleanBkash = bkashNumber.trim();
    if (cleanBkash.isNotEmpty) {
      if (cleanPhone.isNotEmpty) {
        await _paymentBox!.put('bkash_phone_$cleanPhone', cleanBkash);
      }
      if (driverId != null && driverId.isNotEmpty) {
        await _paymentBox!.put('bkash_id_$driverId', cleanBkash);
      }
      await _paymentBox!.put('last_global_bkash', cleanBkash);
    }
  }

  /// Retrieve last used bKash number
  static String? getLastBkashNumber({String? driverPhone, String? driverId}) {
    if (_paymentBox == null) return null;
    if (driverPhone != null && driverPhone.trim().isNotEmpty) {
      final val = _paymentBox!.get('bkash_phone_${driverPhone.trim()}');
      if (val != null && val.toString().trim().isNotEmpty) {
        return val.toString().trim();
      }
    }
    if (driverId != null && driverId.trim().isNotEmpty) {
      final val = _paymentBox!.get('bkash_id_${driverId.trim()}');
      if (val != null && val.toString().trim().isNotEmpty) {
        return val.toString().trim();
      }
    }
    final globalVal = _paymentBox!.get('last_global_bkash');
    if (globalVal != null && globalVal.toString().trim().isNotEmpty) {
      return globalVal.toString().trim();
    }
    return null;
  }

  /// Get all drivers stored in Hive
  static List<DriverModel> getAllDrivers() {
    if (_box == null) return [];
    final List<DriverModel> list = [];
    for (var i = 0; i < _box!.length; i++) {
      final rawData = _box!.getAt(i);
      if (rawData is Map && rawData.containsKey('vehicleType')) {
        list.add(DriverModel.fromMap(rawData));
      }
    }
    return list;
  }

  /// Add new driver
  static Future<void> addDriver(DriverModel driver) async {
    if (_box == null) await init();
    await _box!.put(driver.id, driver.toMap());
  }

  /// Delete driver by ID
  static Future<void> deleteDriver(String id) async {
    if (_box == null) await init();
    await _box!.delete(id);
  }

  /// Note helper methods for NoteProvider compatibility
  static List<NoteModel> getAllNotes() => [];
  static Future<void> addNote(NoteModel note) async {}
  static Future<void> updateNote(NoteModel note) async {}
  static Future<void> deleteNote(String id) async {}

  /// Clear all
  static Future<void> clearAll() async {
    if (_box == null) await init();
    await _box!.clear();
  }
}
