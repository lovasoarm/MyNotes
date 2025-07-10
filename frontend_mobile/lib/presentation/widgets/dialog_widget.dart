import 'package:flutter/material.dart';
import 'package:frontend_mobile/models/notes/notes_model.dart';
import 'package:frontend_mobile/models/auth/auth_model.dart';
import 'package:frontend_mobile/view_models/auth/auth_viewmodel.dart';
import 'package:provider/provider.dart';

Future<bool?> buildShowDialog({
  required BuildContext context,
  required Future<void> Function(Note) onNoteAdded,
  required Future<void> Function(Note) onNoteUpdated,
  Note? existingNote,
}) async {
  final titleController = TextEditingController(text: existingNote?.title ?? '');
  final contentController = TextEditingController(text: existingNote?.content ?? '');

  return await showDialog<bool?>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(existingNote == null ? 'Ajouter une note' : 'Modifier la note'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Titre'),
          ),
          TextField(
            minLines: 4,
            maxLines: 8,
            controller: contentController,
            decoration: const InputDecoration(
              labelText: 'Contenu',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final authViewModel = Provider.of<AuthViewmodel>(context, listen: false);
            final currentUser = authViewModel.currentUser;
            
            if (currentUser == null) {
              // Créer un utilisateur par défaut si non connecté
              final defaultUser = User(
                id: '',
                email: 'utilisateur@local.app',
              );
              
              final note = Note(
                id: existingNote?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text,
                content: contentController.text,
                author: defaultUser,
                createdAt: DateTime.now(),
              );
              
              if (existingNote == null) {
                await onNoteAdded(note);
              } else {
                await onNoteUpdated(note);
              }
            } else {
              final note = Note(
                id: existingNote?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text,
                content: contentController.text,
                author: currentUser,
                createdAt: DateTime.now(),
              );
              
              if (existingNote == null) {
                await onNoteAdded(note);
              } else {
                await onNoteUpdated(note);
              }
            }
            
            if (context.mounted) {
              Navigator.of(context).pop(true);
            }
          },
          child: Text(existingNote == null ? 'Ajouter' : 'Enregistrer'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
      ],
    ),
  );
}