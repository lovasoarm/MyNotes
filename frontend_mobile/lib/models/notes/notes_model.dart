import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/foundation.dart';
import '../auth/auth_model.dart';
import '../../core/graphql/queries.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final User author;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    this.createdAt,
    this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    // Le backend peut retourner soit 'author' soit 'user'
    final userJson = json['author'] ?? json['user'];
    
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      author: User.fromJson(userJson as Map<String, dynamic>),
      createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'] as String)
        : null,
      updatedAt: json['updatedAt'] != null 
        ? DateTime.parse(json['updatedAt'] as String)
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    User? author,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}



class NotesModel {
  List<Note> notes = [];
  final AuthModel authModel;

  NotesModel({required this.authModel});

  GraphQLClient get client => authModel.client;

  // Récupération de toutes les notes depuis le backend et locales
  Future<List<Note>> fetchNotes() async {
    try {
      if (!authModel.isAuthenticated()) {
        if (kDebugMode) {
          print('User not authenticated, cannot fetch notes');
        }
        return [];
      }

      final currentUserId = authModel.user!.id;
      final isGoogleUser = currentUserId.startsWith('google_');
      
      if (kDebugMode) {
        print('UserID utilisé pour fetchNotes: $currentUserId');
      }

      List<Note> backendNotes = [];
      List<Note> localNotes = [];
      
      // Récupérer les notes locales existantes
      localNotes = notes.where((note) => 
        note.author.id == currentUserId || 
        note.id.startsWith('local_')
      ).toList();
      
      // Pour les utilisateurs Google, ne pas essayer le backend
      if (isGoogleUser) {
        if (kDebugMode) {
          print('Utilisateur Google détecté, utilisation des notes locales uniquement');
        }
        notes = localNotes;
        return notes;
      }

      // Pour les utilisateurs classiques, essayer le backend
      try {
        final result = await client.query(
          QueryOptions(
            document: gql(GraphQLQueries.getNotesQuery),
          ),
        );

        if (!result.hasException) {
          final data = result.data?['getAllNotes'];
          if (data != null) {
            backendNotes = (data as List)
                .map((noteData) => Note.fromJson(noteData as Map<String, dynamic>))
                .where((note) => note.author.id == currentUserId)
                .toList();
            
            if (kDebugMode) {
              print('✅ ${backendNotes.length} notes récupérées du backend');
            }
          }
        } else {
          if (kDebugMode) {
            print('❌ Erreur backend: ${result.exception}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Exception backend: $e');
        }
      }

      // Combiner les notes backend et locales
      final allNotes = <Note>[];
      allNotes.addAll(backendNotes);
      allNotes.addAll(localNotes);
      
      // Supprimer les doublons par ID
      final uniqueNotes = <String, Note>{};
      for (final note in allNotes) {
        uniqueNotes[note.id] = note;
      }
      
      notes = uniqueNotes.values.toList();
      
      if (kDebugMode) {
        print('✅ Total de ${notes.length} notes disponibles');
      }
      
      return notes;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception fetchNotes: $e');
      }
      return notes;
    }
  }

  List<Note> getNotes() {
    return notes;
  }



  // Créer une note dans le backend
  Future<Note?> createNote(Note note) async {
    try {
      if (!authModel.isAuthenticated()) {
        if (kDebugMode) {
         // print('User not authenticated, cannot create note');
        }
        return null;
      }

      // Vérifier si c'est un utilisateur Google (ID temporaire)
      final isGoogleUser = authModel.user!.id.startsWith('google_');
      
      if (isGoogleUser) {
        // Pour les utilisateurs Google, créer une note locale
        final localNote = Note(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          title: note.title,
          content: note.content,
          author: authModel.user!,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        notes.add(localNote);
        
        if (kDebugMode) {
          print('✅ Note créée localement pour utilisateur Google: ${localNote.id}');
        }
        
        return localNote;
      }

      // Pour les utilisateurs classiques, essayer le backend
      final result = await client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.createNoteMutation),
          variables: {
            'title': note.title,
            'content': note.content,
            'userId': authModel.user!.id,
          },
        ),
      );

      if (result.hasException) {
        if (kDebugMode) {
          print('❌ Erreur backend, création locale: ${result.exception}');
        }
        
        // Fallback: créer une note locale même pour les utilisateurs classiques
        final localNote = Note(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          title: note.title,
          content: note.content,
          author: authModel.user!,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        notes.add(localNote);
        return localNote;
      }

      final data = result.data?['createNote'];
      if (data != null) {
        final newNote = Note.fromJson(data as Map<String, dynamic>);
        notes.add(newNote);
        
        if (kDebugMode) {
          print('✅ Note créée dans le backend: ${newNote.id}');
        }
        
        return newNote;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception création note: $e');
      }
      
      // Fallback ultime: créer une note locale
      final localNote = Note(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        title: note.title,
        content: note.content,
        author: authModel.user!,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      notes.add(localNote);
      return localNote;
    }
  }



  // Mettre à jour une note dans le backend
  Future<Note?> updateNote(String id, String title, String content) async {
    try {
      if (!authModel.isAuthenticated()) {
        if (kDebugMode) {
         // print('User not authenticated, cannot update note');
        }
        return null;
      }

      final result = await client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.updateNoteMutation),
          variables: {
            'id': id,
            'title': title,
            'content': content,
          },
        ),
      );

      if (result.hasException) {
        if (kDebugMode) {
         // print('Error updating note: ${result.exception}');
        }
        return null;
      }

      final data = result.data?['updateNote'];
      if (data != null && data['success'] == true) {
        // Trouver et mettre à jour la note localement
        int index = notes.indexWhere((note) => note.id == id);
        if (index != -1) {
          final updatedNote = notes[index].copyWith(
            title: title,
            content: content,
            updatedAt: DateTime.now(),
          );
          notes[index] = updatedNote;
          return updatedNote;
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        //print('Exception updating note: $e');
      }
      return null;
    }
  }



  // Supprimer une note du backend
  Future<bool> deleteNote(String id) async {
    try {
      if (!authModel.isAuthenticated()) {
        if (kDebugMode) {
          //print('User not authenticated, cannot delete note');
        }
        return false;
      }

      // Vérifier si c'est une note locale
      final isLocalNote = id.startsWith('local_');
      final isGoogleUser = authModel.user!.id.startsWith('google_');
      
      if (isLocalNote || isGoogleUser) {
        // Supprimer directement la note locale
        notes.removeWhere((note) => note.id == id);
        
        if (kDebugMode) {
          print('✅ Note locale supprimée: $id');
        }
        
        return true;
      }

      // Pour les notes backend, essayer de supprimer via GraphQL
      final result = await client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.deleteNoteMutation),
          variables: {
            'id': id,
          },
        ),
      );

      if (result.hasException) {
        if (kDebugMode) {
          print('❌ Erreur suppression backend, suppression locale: ${result.exception}');
        }
        
        // Fallback: supprimer localement même si le backend échoue
        notes.removeWhere((note) => note.id == id);
        return true;
      }

      final data = result.data?['deleteNote'];
      if (data != null && data['success'] == true) {
        // Supprimer localement
        notes.removeWhere((note) => note.id == id);
        
        if (kDebugMode) {
          print('✅ Note supprimée du backend: $id');
        }
        
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception suppression note: $e');
      }
      
      // Fallback ultime: supprimer localement
      notes.removeWhere((note) => note.id == id);
      return true;
    }
  }



  List<Note> searchNotes(String query) {
    if (query.isEmpty) return getNotes();
    
    String searchQuery = query.toLowerCase().trim();
    
    return getNotes().where((note) {
      String title = note.title.toLowerCase();
      String content = note.content.toLowerCase();

      bool titleMatch = title.contains(searchQuery);
      bool contentMatch = content.contains(searchQuery);

      List<String> keywords = searchQuery.split(RegExp(r'[,\s]+'))
          .where((word) => word.isNotEmpty)
          .toList();
      
      bool keywordMatch = keywords.any((keyword) => 
        title.contains(keyword) || content.contains(keyword)
      );
      
      return titleMatch || contentMatch || keywordMatch;
    }).toList();
  }

  // Recherche de notes depuis le backend
  Future<List<Note>> searchNotesFromBackend(String keyword) async {
    try {
      if (!authModel.isAuthenticated()) {
        if (kDebugMode) {
         // print('User not authenticated, cannot search notes');
        }
        return [];
      }

      final result = await client.query(
        QueryOptions(
          document: gql(GraphQLQueries.searchNotesQuery),
          variables: {
            'filter': {
              'userId': authModel.user!.id,
              'keyword': keyword,
              'limit': 100,
            },
          },
        ),
      );

      if (result.hasException) {
        if (kDebugMode) {
         // print('Error searching notes: ${result.exception}');
        }
        return [];
      }

      final data = result.data?['searchNotes'];
      if (data != null) {
        return (data as List)
            .map((noteData) => Note.fromJson(noteData as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
       // print('Exception searching notes: $e');
      }
      return [];
    }
  }



  /// Filtre les notes créées à une date précise
  List<Note> getNotesByDate(DateTime date) {
    return notes.where((note) {
      if (note.createdAt == null) return false;
      return note.createdAt!.year == date.year &&
             note.createdAt!.month == date.month &&
             note.createdAt!.day == date.day;
    }).toList();
  }


  Note? getNoteById(String id) {
    try {
      return notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }
}
