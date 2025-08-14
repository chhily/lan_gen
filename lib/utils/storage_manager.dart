import 'package:hive/hive.dart';
import 'package:lan_gen/models/translation_data.dart';

class StorageManager {
  StorageManager._();
  static const _exportPathKey = 'export_path';
  static late Box<TranslationData> box;

  static Future<List<TranslationData>> getSavedTranslationDate() async {
    box = await Hive.openBox(_exportPathKey);
    List<TranslationData> translations = box.values.toList();
    translations.sort((a, b) {
      if (a.timeStamps != null && b.timeStamps != null) {
        return a.timeStamps!.compareTo(b.timeStamps!);
      }
      return 0;
    });

    return translations;
  }

  static Future<void> saveTranslation(TranslationData tr) async {
    await box.put(tr.name, tr);
  }

  static Future<void> deleteProject(TranslationData tr) async {
    await box.delete(tr.name);
  }

  static Future clearAll() async {
    await box.clear();
  }
}
