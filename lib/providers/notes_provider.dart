import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/storage_service.dart';

class NotesProvider extends ChangeNotifier {
  List<Note> _notes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  List<Note> get notes {
    List<Note> filtered = _notes;
    if (_searchQuery.isNotEmpty) {
      filtered = _notes
          .where((n) =>
              n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              n.content.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    // Sort: newest first
    filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return filtered;
  }

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();
    _notes = await StorageService.instance.loadNotes();
    _isLoading = false;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    _notes.add(note);
    await _save();
  }

  Future<void> updateNote(Note note) async {
    final idx = _notes.indexWhere((n) => n.id == note.id);
    if (idx != -1) {
      _notes[idx] = note.copyWith(updatedAt: DateTime.now());
      await _save();
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _save();
  }

  Future<void> _save() async {
    await StorageService.instance.saveNotes(_notes);
    notifyListeners();
  }
}
