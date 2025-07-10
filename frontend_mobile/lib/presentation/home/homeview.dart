// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend_mobile/core/constants/colors.dart';
import 'package:frontend_mobile/models/notes/notes_model.dart';
import 'package:frontend_mobile/presentation/home/notes_details_view.dart';
import 'package:frontend_mobile/presentation/widgets/dialog_widget.dart';
import 'package:frontend_mobile/presentation/widgets/animation_widget.dart';
import 'package:frontend_mobile/view_models/notes/notes_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:frontend_mobile/view_models/auth/auth_viewmodel.dart';

class Homeview extends StatefulWidget {
  const Homeview({super.key});

  @override
  _HomeviewState createState() => _HomeviewState();
}

class _HomeviewState extends State<Homeview> {
  final TextEditingController _searchController = TextEditingController();
  List<Note> notesList = [];

  @override
  void initState() {
    super.initState();
    _loadInitialNotes();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadInitialNotes() async {
    try {
      final model = Provider.of<NotesViewmodel>(context, listen: false);
      await model.loadNotes();
      if (!mounted) return;
      setState(() {
        notesList = model.allNotes();
        if (kDebugMode) {
         // print('Notes chargées: ${notesList.length}');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        //print('Erreur lors du chargement des notes: $e');
      }
      return;
    }
  }

  void _onSearchChanged() {
    final model = Provider.of<NotesViewmodel>(context, listen: false);
    setState(() {
      notesList = _searchController.text.isEmpty
          ? model.allNotes()
          : model.searchNotes(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewmodel>(context);
    final model = Provider.of<NotesViewmodel>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: AnimationWidget.slideFromLeft(
          child: const Text(
            'Home',
            style: TextStyle(
              fontFamily: 'DancingScript',
              fontWeight: FontWeight.bold,
              fontSize: 30,
              color: AppColors.primary,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.account_circle, color: AppColors.primary, size: 30),
              onSelected: (value) async {
                if (value == 'logout') {
                  await authViewModel.logout();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
                  }
                }
                return;
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'user',
                  enabled: false,
                  child: Text(
                    authViewModel.currentUser?.email ?? 'Utilisateur',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Déconnexion', style: TextStyle(color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await buildShowDialog(
            context: context,
            onNoteAdded: (note) async {
              try {
                final success = await model.addNote(note);
                if (!mounted) return;
                if (success) {
                  await _loadInitialNotes();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Note ajoutée avec succès'),
                        backgroundColor: AppColors.success,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(model.errorMessage ?? 'Erreur lors de l\'ajout de la note'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (kDebugMode) {
                 // print('Erreur lors de l\'ajout de note: $e');
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erreur lors de l\'ajout de la note'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
              return;
            },
            onNoteUpdated: (_) async {
              return;
            },
          );
        },
        child: const Icon(Icons.add_circle, color: AppColors.primary, size: 30),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 40, bottom: 80),
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                labelText: 'Note à rechercher',
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide(color: AppColors.primary, width: 2.0),
                ),
                labelStyle: TextStyle(color: Colors.black.withAlpha(100)),
              ),
            ),
          ),
          _buildActions(model),
          notesList.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: notesList.asMap().entries.map((entry) {
                    final index = entry.key;
                    final note = entry.value;
                    return AnimationWidget.listItemAnimation(
                      index: index,
                      child: _buildNoteCard(context, model, note),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildActions(NotesViewmodel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                ),
                onPressed: () {
                  setState(() {
                    notesList = model.searchNotes(_searchController.text);
                  });
                },
                child: const Text('Rechercher'),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: model.isLoading ? null : () => _performSync(model),
                icon: model.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.sync, size: 16),
                label: Text(model.isLoading ? 'Sync...' : 'Sync'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.primary),
            onPressed: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              ).then((selectedDate) {
                if (selectedDate != null) {
                  setState(() {
                    notesList = model.getNotesByDate(selectedDate);
                  });
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 100, color: AppColors.primary.withAlpha(200)),
            const SizedBox(height: 20),
            Text(
              'Ajouter vos propres notes',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black.withAlpha(190),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, NotesViewmodel model, Note note) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListTile(
        title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(note.content, maxLines: 3, overflow: TextOverflow.ellipsis),
        trailing: Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: IconButton(
            icon: const Icon(Icons.delete, color: AppColors.delete),
            onPressed: () async {
              final success = await model.deleteNote(note.id);
              if (success && mounted) {
                await _loadInitialNotes();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Note supprimée avec succès'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(model.errorMessage ?? 'Erreur lors de la suppression'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
              return;
            },
          ),
        ),
        onTap: () async {
          final refreshNeeded = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotesDetailsView(
                noteId: note.id,
                noteTitle: note.title,
                noteContent: note.content,
                model: model,
              ),
            ),
          );
          if (refreshNeeded == true && mounted) {
            await _loadInitialNotes();
          }
          return;
        },
      ),
    );
  }

  Future<void> _performSync(NotesViewmodel model) async {
    try {
      final isConnected = await model.checkFirebaseConnection();
      if (!isConnected) {
        _showSyncMessage('Pas de connexion Firebase', isError: true);
        return;
      }

      final success = await model.performIntelligentSync();
      if (!mounted) return;

      if (success) {
        await _loadInitialNotes();
        _showSyncMessage('Synchronisation réussie !', isError: false);
      } else {
        _showSyncMessage(model.errorMessage ?? 'Erreur de synchronisation', isError: true);
      }
    } catch (e) {
      if (kDebugMode) {
       // print('Erreur lors de la synchronisation: $e');
      }
      _showSyncMessage('Erreur lors de la synchronisation', isError: true);
    }
    return;
  }

  void _showSyncMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error : Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
