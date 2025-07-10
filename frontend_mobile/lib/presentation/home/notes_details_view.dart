// ignore_for_file: must_be_immutable, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:frontend_mobile/core/constants/colors.dart';
import 'package:frontend_mobile/presentation/widgets/dialog_widget.dart';
import 'package:frontend_mobile/presentation/widgets/animation_widget.dart';
import 'package:frontend_mobile/view_models/notes/notes_viewmodel.dart';

class NotesDetailsView extends StatefulWidget {
   NotesDetailsView({ super.key, 
  required this.noteId,
  required this.noteTitle,
  required this.noteContent,
  required this.model,
  });
  final String noteId;
  String noteTitle;
  String noteContent;
  final NotesViewmodel model;

  @override
  _NotesDetailsViewState createState() => _NotesDetailsViewState();
}

class _NotesDetailsViewState extends State<NotesDetailsView> {
  bool isInDetailsView = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: Text(widget.noteTitle, style: TextStyle(color: AppColors.primary,fontFamily: 'DancingScript', fontSize: 30))),
            Row(
              children: [
                const SizedBox(width: 15),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary, size: 30),
                  onPressed: () async {
                            final result = await buildShowDialog(
                            context: context,
                            onNoteAdded: (_) async {},
                            onNoteUpdated: (updatedNote) async {
                              final success = await widget.model.updateNote(
                                updatedNote.id,
                                updatedNote.title,
                                updatedNote.content,
                              );
      
                if (success && mounted) {
                      setState(() {
                          widget.noteTitle = updatedNote.title;
                          widget.noteContent = updatedNote.content;
                        });
                } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(widget.model.errorMessage ?? 'Erreur lors de la modification de la note'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                }
          },
    
    // existingNote: Note(
    //   id: widget.noteId,
    //   title: widget.noteTitle,
    //   content: widget.noteContent,
    //   author: User(id: 1, email: 'temp@user.local'),
    // ),
  );
  
                    // Si une note a été mise à jour, on retourne à HomeView avec true
                    if (result == true) {
                      Navigator.pop(context, true);
                    }
       },
    ),
                const SizedBox(width: 15),
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.delete, size: 30),
                  onPressed: () async {
                    final success = await widget.model.deleteNote(widget.noteId);
                    if (success && mounted) {
                      Navigator.pop(context, true);
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(widget.model.errorMessage ?? 'Erreur lors de la suppression de la note'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(width: 15),
              ],
            ),
            
          ],
        ),
        
  
      ),
      body: AnimationWidget.fadeIn(
        child: Column(
          children: [
             // test : Text('Details for note ID: ${widget.noteId}'),
             const SizedBox(height: 10),
             AnimationWidget.slideFromBottom(
               delay: 0.2,
               child: Padding(
                 padding: const EdgeInsets.all(20.0),
                 child: Text(widget.noteContent, style: const TextStyle(fontSize: 18,color: AppColors.secondary) ),
               ),
             ),
          ],
        ),
      ),
    );
  }
}