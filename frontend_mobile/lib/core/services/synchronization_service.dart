import 'package:flutter/foundation.dart';
import '../../models/notes/notes_model.dart';
import '../../models/auth/auth_model.dart';
import 'firebase_service.dart';


/// Résultat de synchronisation
class SyncResult {
  final bool success;
  final String message;
  final List<Note> syncedNotes;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncedNotes,
  });
}

/// Service de synchronisation centralisé
class SynchronizationService {
  
  /// Synchronise un utilisateur avec Firebase
  static Future<bool> syncUser(User user) async {
    try {
      return await FirebaseService.syncUser(user);
    } catch (e) {
      if (kDebugMode) {
      //  print('Erreur sync utilisateur: $e');
      }
      return false;
    }
  }

  /// Synchronisation intelligente complète
  static Future<SyncResult> performIntelligentSync({
    required List<Note> localNotes,
    required User user,
  }) async {
    try {
      // 1. Sync utilisateur d'abord
      final userSynced = await syncUser(user);
      if (!userSynced) {
        return SyncResult(
          success: false,
          message: 'Erreur synchronisation utilisateur',
          syncedNotes: localNotes,
        );
      }

      // 2. Sync intelligent des notes
      final mergedNotes = await FirebaseService.performIntelligentSync(
        localNotes,
        user,
      );

      return SyncResult(
        success: true,
        message: 'Synchronisation réussie: ${mergedNotes.length} notes',
        syncedNotes: mergedNotes,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Erreur sync intelligent: $e');
      }
      return SyncResult(
        success: false,
        message: 'Erreur de synchronisation',
        syncedNotes: localNotes,
      );
    }
  }

  /// Synchronise une note individuelle
  static Future<bool> syncNote(Note note) async {
    try {
      return await FirebaseService.syncNoteToFirestore(note);
    } catch (e) {
      if (kDebugMode) {
       // print('Erreur sync note: $e');
      }
      return false;
    }
  }

  /// Supprime une note de Firebase
  static Future<bool> deleteNoteFromCloud(String noteId) async {
    try {
      return await FirebaseService.deleteNoteFromFirestore(noteId);
    } catch (e) {
      if (kDebugMode) {
       // print('Erreur suppression Firebase: $e');
      }
      return false;
    }
  }

  /// Vérifie la connectivité Firebase
  static Future<bool> checkConnection() async {
    try {
      return await FirebaseService.checkFirebaseConnection();
    } catch (e) {
      return false;
    }
  }

  /// Récupère les notes depuis Firebase
  static Future<List<Note>> fetchNotesFromCloud(User user) async {
    try {
      return await FirebaseService.fetchNotesFromFirestore(user);
    } catch (e) {
      if (kDebugMode) {
        //print('Erreur récupération Firebase: $e');
      }
      return [];
    }
  }
}

