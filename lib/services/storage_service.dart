import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class StorageService {
  static const String _notesKey = 'notes_data';
  static StorageService? _instance;
  SharedPreferences? _prefs;

  StorageService._();

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<Note>> loadNotes() async {
    _prefs ??= await SharedPreferences.getInstance();
    final String? notesJson = _prefs!.getString(_notesKey);
    if (notesJson == null) return [];

    try {
      final List<dynamic> notesList =
          jsonDecode(notesJson) as List<dynamic>;
      return notesList
          .map((e) => Note.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveNotes(List<Note> notes) async {
    _prefs ??= await SharedPreferences.getInstance();
    final String notesJson =
        jsonEncode(notes.map((e) => e.toJson()).toList());
    await _prefs!.setString(_notesKey, notesJson);
  }
}
