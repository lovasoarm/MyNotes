import 'package:flutter/material.dart';
import 'package:frontend_mobile/core/constants/colors.dart';
import 'package:provider/provider.dart';
import '../view_models/auth/auth_viewmodel.dart';
import '../view_models/notes/notes_viewmodel.dart';

/// Widgets d'état centralisés
class StateWidgets {
  
  /// Configuration de tous les providers de l'application
  static List<ChangeNotifierProvider> getProviders() {
    return [
      ChangeNotifierProvider<AuthViewmodel>(
        create: (_) => AuthViewmodel(),
      ),
      ChangeNotifierProvider<NotesViewmodel>(
        create: (context) => NotesViewmodel(
          authModel: Provider.of<AuthViewmodel>(context, listen: false).myModel,
        ),
      ),
    ];
  }

  /// Widget racine avec tous les providers
  static Widget buildAppWithProviders({required Widget child}) {
    return MultiProvider(
      providers: getProviders(),
      child: child,
    );
  }
}

/// Utility pour afficher des SnackBars
class SnackBarUtils {
  
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context: context,
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  static void showError(BuildContext context, String message) {
    _showSnackBar(
      context: context,
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error,
    );
  }
 
  // static void showInfo(BuildContext context, String message) {
  //   _showSnackBar(
  //     context: context,
  //     message: message,
  //     backgroundColor: Colors.blue,
  //     icon: Icons.info,
  //   );
  // }

  static void _showSnackBar({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppColors.background, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
