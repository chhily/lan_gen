import 'package:hive/hive.dart';
import 'package:lan_gen/models/translation_data.dart';

class StorageManager {
  StorageManager._();

  static const _boxName = 'export_path';
  static Box<UserTranslationData>? _box;

  /// Internal getter that ensures the box is open before use
  static Future<Box<UserTranslationData>> _getBox() async {
    if (_box?.isOpen ?? false) return _box!;
    _box = await Hive.openBox<UserTranslationData>(_boxName);
    return _box!;
  }

  static Future<List<UserTranslationData>> getSavedTranslationDate() async {
    final box = await _getBox();
    final translations = box.values.toList();
    translations.sort((a, b) {
      if (a.timeStamps != null && b.timeStamps != null) {
        return a.timeStamps!.compareTo(b.timeStamps!);
      }
      return 0;
    });
    return translations;
  }

  static Future<void> saveTranslation(UserTranslationData tr) async {
    final box = await _getBox();
    await box.put(tr.name, tr);
  }

  static Future<void> deleteProject(UserTranslationData tr) async {
    final box = await _getBox();
    await box.delete(tr.name);
  }

  static Future<void> clearAll() async {
    final box = await _getBox();
    await box.clear();
  }
}
