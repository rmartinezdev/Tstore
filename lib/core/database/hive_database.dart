import 'package:hive_flutter/hive_flutter.dart';
import 'package:tstore/core/constants/app_constants.dart';
import 'package:tstore/core/utils/logger.dart';

class HiveDatabase {
  HiveDatabase._();

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      Log.info('Hive Database initialized.');

      // Open all e-commerce boxes
      await _openBoxes();
    } catch (e, stackTrace) {
      Log.error('Failed to initialize Hive Database', error: e, stackTrace: stackTrace);
    }
  }

  static Future<void> _openBoxes() async {
    await Future.wait([
      Hive.openBox(AppConstants.productsBox),
      Hive.openBox(AppConstants.categoriesBox),
      Hive.openBox(AppConstants.cartBox),
      Hive.openBox(AppConstants.favoritesBox),
      Hive.openBox(AppConstants.ordersBox),
      Hive.openBox(AppConstants.appConfigBox),
    ]);
    Log.debug('All Hive boxes opened successfully.');
  }

  // Generic methods to read/write from boxes
  static Future<void> put(String boxName, String key, dynamic value) async {
    final box = Hive.box(boxName);
    await box.put(key, value);
  }

  static dynamic get(String boxName, String key, {dynamic defaultValue}) {
    final box = Hive.box(boxName);
    return box.get(key, defaultValue: defaultValue);
  }

  static Future<void> delete(String boxName, String key) async {
    final box = Hive.box(boxName);
    await box.delete(key);
  }

  static Future<void> clear(String boxName) async {
    final box = Hive.box(boxName);
    await box.clear();
  }

  static List<dynamic> getAll(String boxName) {
    final box = Hive.box(boxName);
    return box.values.toList();
  }

  static Map<String, dynamic> getAllAsMap(String boxName) {
    final box = Hive.box(boxName);
    return Map<String, dynamic>.from(box.toMap());
  }

  static Future<void> putAll(String boxName, Map<String, dynamic> entries) async {
    final box = Hive.box(boxName);
    await box.putAll(entries);
  }
}
