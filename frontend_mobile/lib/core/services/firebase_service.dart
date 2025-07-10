import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/notes/notes_model.dart';
import '../../models/auth/auth_model.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection pour les utilisateurs
  static const String _usersCollection = 'users';
  // Collection pour les notes
  static const String _notesCollection = 'notes';

  /// Synchronise un utilisateur avec Firestore (bd any anaty firebase)
  static Future<bool> syncUser(User user) async {
    try {
          await _firestore.collection(_usersCollection).doc(user.id.toString()).set({
            'id': user.id,
            'email': user.email,
            'createdAt': FieldValue.serverTimestamp(),
            'lastSyncAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      
      //Test bug
      if (kDebugMode) {
      //  print('OK:  Utilisateur synchronisé avec Firebase: ${user.email}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
       // print(' Erreur lors de la synchronisation utilisateur: $e');
      }
      return false;
    }
  }

  /// Synchronise les notes locales vers Firestore
  static Future<bool> syncNotesToFirestore(List<Note> notes, User user) async {
    try {
      final batch = _firestore.batch();
      
      for (Note note in notes) {
              final noteRef = _firestore.collection(_notesCollection).doc(note.id);
              batch.set(noteRef, {
                'id': note.id,
                'title': note.title,
                'content': note.content,
                'authorId': note.author.id,
                'authorEmail': note.author.email,
                'createdAt': note.createdAt?.millisecondsSinceEpoch ?? FieldValue.serverTimestamp(),
                'updatedAt': note.updatedAt?.millisecondsSinceEpoch ?? FieldValue.serverTimestamp(),
                'lastSyncAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
      }
      
      await batch.commit();
      
      //
      if (kDebugMode) {
       // print('OK : ${notes.length} notes synchronisées vers Firebase');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        //print('Erreur lors de la synchronisation vers Firebase: $e');
      }
      return false;
    }
  }

  /// Récupèration des notes depuis Firestore
  static Future<List<Note>> fetchNotesFromFirestore(User user) async {
    try {
      final querySnapshot = await _firestore
              .collection(_notesCollection)
              .where('authorId', isEqualTo: user.id)
              .get();

      final notes = <Note>[];
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        
        // Convertissons les timestamps Firestore en DateTime
        DateTime? createdAt;
        DateTime? updatedAt;
        
        if (data['createdAt'] is Timestamp) {
          createdAt = (data['createdAt'] as Timestamp).toDate();
        } else if (data['createdAt'] is int) {
          createdAt = DateTime.fromMillisecondsSinceEpoch(data['createdAt']);
        }
        
        if (data['updatedAt'] is Timestamp) {
          updatedAt = (data['updatedAt'] as Timestamp).toDate();
        } else if (data['updatedAt'] is int) {
          updatedAt = DateTime.fromMillisecondsSinceEpoch(data['updatedAt']);
        }
        
        final note = Note(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          author: user,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
        
        notes.add(note);
      }
      
      if (kDebugMode) {
        print('OK: ${notes.length} notes récupérées depuis Firebase');
      }
      return notes;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération depuis Firebase: $e');
      }
      return [];
    }
  }

  /// Synchronisation d'une note spécifique vers Firestore
  static Future<bool> syncNoteToFirestore(Note note) async {
    try {
      await _firestore.collection(_notesCollection).doc(note.id).set({
        'id': note.id,
        'title': note.title,
        'content': note.content,
        'authorId': note.author.id,
        'authorEmail': note.author.email,
        'createdAt': note.createdAt?.millisecondsSinceEpoch ?? FieldValue.serverTimestamp(),
        'updatedAt': note.updatedAt?.millisecondsSinceEpoch ?? FieldValue.serverTimestamp(),
        'lastSyncAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      if (kDebugMode) {
        //print('OK: Note synchronisée vers Firebase: ${note.title}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la synchronisation de la note: $e');
      }
      return false;
    }
  }

  /// Supprime une note de Firestore
  static Future<bool> deleteNoteFromFirestore(String noteId) async {
    try {
      await _firestore.collection(_notesCollection).doc(noteId).delete();
      
      if (kDebugMode) {
        print('OK: Note supprimée de Firebase: $noteId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la suppression de Firebase: $e');
      }
      return false;
    }
  }

  /// Vérifie la connectivité à Firestore
  static Future<bool> checkFirebaseConnection() async {
    try {
      await _firestore.collection('test').doc('connection').get();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(' Pas de connexion Firebase: $e');
      }
      return false;
    }
  }

  /// Synchronisation bidirectionnelle intelligente : traite les conflits et fusionne les notes (anisany mampatsiro ny flutter)
  static Future<List<Note>> performIntelligentSync(List<Note> localNotes, User user) async {
    try {
  
      final firebaseNotes = await fetchNotesFromFirestore(user);
      
      // Maps pour faciliter la comparaison
      final localNotesMap = {for (var note in localNotes) note.id: note};
      final firebaseNotesMap = {for (var note in firebaseNotes) note.id: note};
      
      final batch = _firestore.batch();
      final mergedNotes = <Note>[];
      
      // Traitement des notes Firebase
      for (var firebaseNote in firebaseNotes) {
        final localNote = localNotesMap[firebaseNote.id];
        
        if (localNote == null) {
          // Note uniquement sur Firebase - l'ajouter localement
          mergedNotes.add(firebaseNote);
        } else {
          // Note existe des deux côtés - prendre la plus récente
          if (firebaseNote.updatedAt != null && localNote.updatedAt != null) {
            if (firebaseNote.updatedAt!.isAfter(localNote.updatedAt!)) {
              mergedNotes.add(firebaseNote);
            } else {
              mergedNotes.add(localNote);
              // Synchroniser la version locale vers Firebase si elle est plus récente
              final noteRef = _firestore.collection(_notesCollection).doc(localNote.id);
              batch.set(noteRef, {
                'id': localNote.id,
                'title': localNote.title,
                'content': localNote.content,
                'authorId': localNote.author.id,
                'authorEmail': localNote.author.email,
                'createdAt': localNote.createdAt?.millisecondsSinceEpoch ?? FieldValue.serverTimestamp(),
                'updatedAt': localNote.updatedAt?.millisecondsSinceEpoch ?? FieldValue.serverTimestamp(),
                'lastSyncAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
            }
          } else {
            // Si pas de timestamps, prendre la version locale
            mergedNotes.add(localNote);
          }
        }
      }
      
      // Traiter les notes locales qui ne sont pas sur Firebase
      for (var localNote in localNotes) {
        if (!firebaseNotesMap.containsKey(localNote.id)) {
          mergedNotes.add(localNote);
          // Synchroniser vers Firebase
          final noteRef = _firestore.collection(_notesCollection).doc(localNote.id);
          batch.set(noteRef, {
            'id': localNote.id,
            'title': localNote.title,
            'content': localNote.content,
            'authorId': localNote.author.id,
            'authorEmail': localNote.author.email,
            'createdAt': localNote.createdAt?.millisecondsSinceEpoch ?? FieldValue.serverTimestamp(),
            'updatedAt': localNote.updatedAt?.millisecondsSinceEpoch ?? FieldValue.serverTimestamp(),
            'lastSyncAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }
      
      // Exécuter les changements en batch si des modifications sont nécessaires
      try {
        await batch.commit();
      } catch (e) {
        if (kDebugMode) {
          print('Batch commit: $e');
        }
      }
      
      if (kDebugMode) {
       // print('OK: Synchronisation intelligente terminée: ${mergedNotes.length} notes');
      }
      
      return mergedNotes;
    } catch (e) {
      if (kDebugMode) {
        print(' Erreur lors de la synchronisation intelligente: $e');
      }
      return localNotes; // En cas d'erreur, retourner les notes locales
    }
  }
}
