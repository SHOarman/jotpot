import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/hive_service.dart';

class NoteProvider extends ChangeNotifier {
  List<NoteModel> _notes = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isGridView = true;
  bool _isLoading = false;

  NoteProvider() {
    loadNotes();
  }

  List<NoteModel> get notes => _notes;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isGridView => _isGridView;
  bool get isLoading => _isLoading;

  List<String> get categories => [
        'All',
        'General',
        'Work',
        'Personal',
        'Ideas',
        'Tasks',
      ];

  /// Get filtered and searched list of notes
  List<NoteModel> get filteredNotes {
    return _notes.where((note) {
      final matchesSearch = note.title
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          note.content.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'All' ||
          note.category.toLowerCase() == _selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();
  }

  /// Load notes from Hive database
  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = HiveService.getAllNotes();
    } catch (e) {
      debugPrint('Error loading notes from Hive: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new note
  Future<void> addNote(NoteModel note) async {
    await HiveService.addNote(note);
    await loadNotes();
  }

  /// Update an existing note
  Future<void> updateNote(NoteModel note) async {
    await HiveService.updateNote(note);
    await loadNotes();
  }

  /// Delete note by ID
  Future<void> deleteNote(String id) async {
    await HiveService.deleteNote(id);
    await loadNotes();
  }

  /// Toggle Pin status of note
  Future<void> togglePinNote(NoteModel note) async {
    final updatedNote = note.copyWith(isPinned: !note.isPinned);
    await updateNote(updatedNote);
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Set selected category filter
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Toggle grid / list view
  void toggleLayoutView() {
    _isGridView = !_isGridView;
    notifyListeners();
  }
}
