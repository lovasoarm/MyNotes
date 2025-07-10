
import 'package:flutter/foundation.dart';
import '../../models/notes/notes_model.dart';
import '../../models/auth/auth_model.dart';
import '../../core/services/synchronization_service.dart';

class NotesViewmodel extends ChangeNotifier {
  late NotesModel myModel;
  List<Note> _notesList = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<Note> get notesList => _notesList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  NotesViewmodel({required AuthModel authModel}) {
    myModel = NotesModel(authModel: authModel);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Charger les notes depuis le backend
  Future<void> loadNotes() async {
    _setLoading(true);
    _setError(null);
    
    try {
      _notesList = await myModel.fetchNotes();
      _setLoading(false);
    } catch (e) {
      _setError('Erreur lors du chargement des notes');
      _setLoading(false);
    }
   // print("UserID utilisé pour fetchNotes: ${myModel.authModel.user?.id}");

  }

  List<Note> allNotes() {
    _notesList = myModel.getNotes();
    return _notesList;
  }

  Future<bool> updateNote(String id, String titre, String content) async {
      _setLoading(true);
      _setError(null);
      
      try {
        final updatedNote = await myModel.updateNote(id, titre, content);
        
        if (updatedNote != null) {
          _notesList = myModel.getNotes();
          syncNote(updatedNote);
          
          _setLoading(false);
          notifyListeners();
          return true;
        } else {
          _setError('Erreur lors de la modification de la note');
          _setLoading(false);
          return false;
        }
      } catch (e) {
        _setError('Erreur de connexion lors de la modification');
        _setLoading(false);
        return false;
      }
  }
  

  Future<bool> addNote(Note note) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final createdNote = await myModel.createNote(note);
      
      if (createdNote != null) {
        // Mettre à jour la liste locale immédiatement ho an'ny affichage
        _notesList = myModel.getNotes();
        syncNote(createdNote);
        
        _setLoading(false);
        notifyListeners();
        
        if (kDebugMode) {
          // print(' Note ajoutée avec succès: ${createdNote.id}');
          // print(' Nombre total de notes: ${_notesList.length}');
        }
        
        return true;
      } else {
        _setError('Erreur lors de la création de la note');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Erreur de connexion lors de la création');
      _setLoading(false);
      return false;
    }
  }

  List<Note> searchNotes(String query) {
    List<Note> results = myModel.searchNotes(query);
    notifyListeners();
    return results;
  }

  List<Note> getNotesByDate(DateTime date) {
    _notesList = myModel.getNotesByDate(date);
    notifyListeners();
    return _notesList;
  }
  
  Future<bool> deleteNote(String id) async {
    _setLoading(true);
    _setError(null);
    
    try {
      final success = await myModel.deleteNote(id);
      
      if (success) {
        await SynchronizationService.deleteNoteFromCloud(id);
        _notesList = myModel.getNotes();
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Erreur lors de la suppression de la note');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Erreur de connexion lors de la suppression');
      _setLoading(false);
      return false;
    }
  }

  /// Synchronisation intelligente principale
  Future<SyncResult> performSync() async {
    if (!_isUserAuthenticated()) {
      return SyncResult(
        success: false,
        message: 'Utilisateur non authentifié',
        syncedNotes: _notesList,
      );
    }

    _setLoading(true);
    _setError(null);

    final result = await SynchronizationService.performIntelligentSync(
      localNotes: _getCurrentNotes(),
      user: myModel.authModel.user!,
    );

    if (result.success) {
      _updateNotesFromSync(result.syncedNotes);
    } else {
      _setError(result.message);
    }

    _setLoading(false);
    return result;
  }

  Future<void> syncNote(Note note) async {
    if (_isUserAuthenticated()) {
      SynchronizationService.syncNote(note);
    }
  }
  Future<bool> checkFirebaseConnection() async {
    return await SynchronizationService.checkConnection();
  }


  Future<bool> checkConnection() async {
    return await SynchronizationService.checkConnection();
  }

  Future<bool> performIntelligentSync() async {
    final result = await performSync();
    return result.success;
  }


  bool _isUserAuthenticated() {
    return myModel.authModel.isAuthenticated();
  }

  List<Note> _getCurrentNotes() {
    return _notesList.isNotEmpty ? _notesList : myModel.getNotes();
  }

  void _updateNotesFromSync(List<Note> syncedNotes) {
    myModel.notes = syncedNotes;
    _notesList = syncedNotes;
    notifyListeners();
  }
}
