import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataService {
  Future<void> exportData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final Map<String, dynamic> data = {};

    for (String key in keys) {
      data[key] = prefs.get(key);
    }

    final String jsonString = jsonEncode(data);
    final Directory tempDir = await getTemporaryDirectory();
    final File file = File('${tempDir.path}/focus_flow_export.json');
    await file.writeAsString(jsonString);

    await Share.shareXFiles([XFile(file.path)], text: 'My Focus Flow Data Export');
  }

  Future<bool> importData() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String content = await file.readAsString();
      Map<String, dynamic> data = jsonDecode(content);

      final prefs = await SharedPreferences.getInstance();
      for (var entry in data.entries) {
        if (entry.value is int) {
          await prefs.setInt(entry.key, entry.value);
        } else if (entry.value is double) {
          await prefs.setDouble(entry.key, entry.value);
        } else if (entry.value is bool) {
          await prefs.setBool(entry.key, entry.value);
        } else if (entry.value is String) {
          await prefs.setString(entry.key, entry.value);
        } else if (entry.value is List) {
          await prefs.setStringList(entry.key, List<String>.from(entry.value));
        }
      }
      return true;
    }
    return false;
  }
}
