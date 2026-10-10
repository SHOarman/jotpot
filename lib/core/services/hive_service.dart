import 'package:hive_flutter/hive_flutter.dart';
import '../models/driver_model.dart';
import '../models/note_model.dart';

class HiveService {
  static const String _boxName = 'jotpot_drivers_box';
  static Box? _box;

  /// Initialize Hive and open driver directory box
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    
    // Seed mock initial data if empty
    if (_box!.isEmpty) {
      await _seedMockData();
    }
  }

  static Future<void> _seedMockData() async {
    final mockDrivers = [
      DriverModel(
        id: '1',
        name: 'new',
        phone: '01677234297',
        vehicleType: 'Bus',
        division: 'ঢাকা',
        district: 'ঢাকা',
        upazila: 'ধামরাই',
        union: 'ধামরাই পৌরসভা',
        ward: 'ওয়ার্ড ১',
        address: 'abc, ধামরাই, ঢাকা',
        details: 'ijwirw',
        seatCount: 25,
      ),
      DriverModel(
        id: '2',
        name: 'Doyal',
        phone: '01712345678',
        vehicleType: 'Private প্রাইভেট কার',
        division: 'ঢাকা',
        district: 'টাঙ্গাইল',
        upazila: 'টাঙ্গাইল সদর',
        union: 'বাঘিল ইউনিয়ন',
        ward: 'ওয়ার্ড ২',
        address: 'Baghil, টাঙ্গাইল সদর, টাঙ্গাইল',
        details: 'allion 2004',
      ),
      DriverModel(
        id: '3',
        name: 'আলমগীর হোসেন',
        phone: '01711223344',
        vehicleType: 'Car',
        division: 'ঢাকা',
        district: 'গাজীপুর',
        upazila: 'টঙ্গী',
        union: 'টঙ্গী পৌরসভা',
        ward: 'ওয়ার্ড ৩',
        address: 'স্টেশন রোড, টঙ্গী, গাজীপুর',
        details: '১৫ বছর অভিজ্ঞ চালক, এসি কার সার্ভিস',
        seatCount: 4,
      ),
      DriverModel(
        id: '4',
        name: 'মাসুদ রানা',
        phone: '01912345678',
        vehicleType: 'Ambulance',
        division: 'ঢাকা',
        district: 'ঢাকা',
        upazila: 'সাভার',
        union: 'সাভার পৌরসভা',
        ward: 'ওয়ার্ড ৫',
        address: 'সাভার বাসস্ট্যান্ড, ঢাকা',
        details: '২৪ ঘণ্টা জরুরী এম্বুলেন্স সেবা',
        seatCount: 2,
      ),
    ];

    for (var driver in mockDrivers) {
      await _box!.put(driver.id, driver.toMap());
    }

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
