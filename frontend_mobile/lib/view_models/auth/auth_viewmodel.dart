// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import '../../models/auth/auth_model.dart';
import '../../core/services/synchronization_service.dart';

class AuthResult {
  final bool success;
  final String message;
  AuthResult({required this.success, required this.message});
}
class AuthViewmodel extends ChangeNotifier {
  final AuthModel myModel = AuthModel();
  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  User? get currentUser => myModel.user;
  bool get isAuthenticated => myModel.isAuthenticated();
  String? get successMessage => _successMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }


  void clearMessages() {
    _successMessage = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Connexion utilisateur
Future<AuthResult> login(String email, String password) async {
  _setLoading(true);
  try {
    final result = await myModel.login(email, password);
    _setLoading(false);

    if (result != null && result.user != null) {
      myModel.user = result.user; 
      notifyListeners();
      return AuthResult(success: true, message: 'Revoilà ${result.user.email}');
    } else {
      return AuthResult(success: false, message: 'Email ou mot de passe incorrect');
    }
  } catch (e) {
    _setLoading(false);
    return AuthResult(success: false, message: 'Erreur de connexion');
  }
}


  /// Inscription utilisateur
  Future<AuthResult> register(String email, String password, String confirmPassword) async {
          if (password != confirmPassword) {
            return AuthResult(success: false, message: 'Les mots de passe ne correspondent pas');
          }
          
          _setLoading(true);
          
          try {
            final result = await myModel.register(email, password);
            _setLoading(false);
            
            if (result != null) {
         
              myModel.user = result; 
              _syncUserToFirebase(result);
              return AuthResult(success: true, message: 'Bienvenue ${result.email}');
            } else {
              return AuthResult(success: false, message: 'Email déjà utilisé');
            }
          } catch (e) {
            _setLoading(false);
            return AuthResult(success: false, message: 'Erreur de connexion');
          }
  }

  /// Authentification Google
  Future<AuthResult> signInWithGoogle() async {
    _setLoading(true);
    
    try {
      final result = await myModel.signInWithGoogle();
      _setLoading(false);
      
      if (result != null) {
        return AuthResult(
          success: true, 
          message: 'Connexion réussie avec Google pour ${result.user.email}'
        );
      } else {
        return AuthResult(
          success: false, 
          message: 'Connexion Google annulée ou échouée'
        );
      }
    } catch (e) {
      _setLoading(false);
      return AuthResult(
        success: false, 
        message: 'Erreur technique lors de la connexion Google: ${e.toString()}'
      );
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    await myModel.logout();
    notifyListeners();
  }

  /// Synchronisation Firebase silencieuse
  Future<void> _syncUserToFirebase(User user) async {
    try {
      await SynchronizationService.syncUser(user);
    } catch (e) {
      // Sync en arrière-plan, Méthode intélligent
    }
  }
}


