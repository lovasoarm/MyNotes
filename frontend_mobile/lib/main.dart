import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/notes_app.dart';
import 'state_management/state_widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase pour toutes les plateformes
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
     // print('Firebase initialisé avec succès');
    }
  } catch (e) {
    if (kDebugMode) {
      //print('Erreur initialisation Firebase: $e');
    }
  }
  
  runApp(
    StateWidgets.buildAppWithProviders(
      child: const Notesapp(),
    ),
  );
}




