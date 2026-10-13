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
    
    // Clear any previous mock/dummy data so only real Firestore data exists
    await _box!.clear();
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
