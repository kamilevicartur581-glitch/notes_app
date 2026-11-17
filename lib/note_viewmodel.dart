import 'package:flutter/foundation.dart';
import 'note.dart';           // было: '../../data/local/entity/note.dart'
import 'note_repository.dart';// было: '../../repository/note_repository.dart'

class NoteViewModel extends ChangeNotifier {
  final NoteRepository _repository;
  NoteViewModel(this._repository);

  // --- State ---
  List<Note> _notes = [];
  List<Note> get notes => _notes;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Текст, введённый в диалоговом окне (переживает rebuild / поворот)
  String _draftTitle = '';
  String get draftTitle => _draftTitle;

  String _draftContent = '';
  String get draftContent => _draftContent;

  // Сообщение об ошибке (MutableLiveData-аналог)
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // --- Load ---
  Future<void> loadNotes() async {
    _notes = _searchQuery.isEmpty
        ? await _repository.getAllNotes()
        : await _repository.searchNotes(_searchQuery);
    notifyListeners();
  }

  // --- Search (Задание Б) ---
  Future<void> setSearchQuery(String query) async {
    _searchQuery = query;
    await loadNotes();
  }

  // --- Draft (сохранение ввода при повороте) ---
  void updateDraftTitle(String v) {
    _draftTitle = v;
    _errorMessage = null;
    notifyListeners();
  }

  void updateDraftContent(String v) {
    _draftContent = v;
    _errorMessage = null;
    notifyListeners();
  }

  void clearDraft() {
    _draftTitle = '';
    _draftContent = '';
    _errorMessage = null;
    notifyListeners();
  }

  // --- Валидация (Задание А) ---
  bool get isDraftValid =>
      _draftTitle.trim().isNotEmpty || _draftContent.trim().isNotEmpty;

  Future<bool> saveDraft() async {
    if (!isDraftValid) {
      _errorMessage = 'Заметка не может быть пустой';
      notifyListeners();
      return false;
    }
    final note = Note(
      title: _draftTitle.trim(),
      content: _draftContent.trim(),
    );
    await _repository.insert(note);
    clearDraft();
    await loadNotes();
    return true;
  }

  // --- Delete ---
  Future<void> deleteNote(Note note) async {
    await _repository.delete(note);
    await loadNotes();
  }
}