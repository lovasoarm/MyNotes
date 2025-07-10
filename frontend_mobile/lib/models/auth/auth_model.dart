import 'package:graphql_flutter/graphql_flutter.dart';
import '../../core/config/graphql_config.dart';
import '../../core/graphql/queries.dart';
import '../../core/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

class User {
  final String id;
  final String email;
  String? password;
  
  User({
    required this.id,
    required this.email,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
    };
  }
}

class AuthResponse {
  final String accessToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class AuthModel {
  User? user;
  String? _accessToken;
  GraphQLClient? _client;
  late StorageService _storageService;

  AuthModel({this.user}) {
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    _storageService = await StorageService.getInstance();
    await _loadStoredUser();
  }

  String? get accessToken => _accessToken;
  
  GraphQLClient get client {
    _client ??= GraphQLConfig.createClient(token: _accessToken);
    return _client!;
  }

  // Load user data from storage
  Future<void> _loadStoredUser() async {
    final token = await _storageService.getToken();
    final userId = await _storageService.getUserId();
    final userEmail = await _storageService.getUserEmail();
    
    if (token != null && userId != null && userEmail != null) {
      _accessToken = token;
      user = User(id: userId, email: userEmail);
      _client = GraphQLConfig.createClient(token: _accessToken);
    }
  }

  Future<AuthResponse?> login(String email, String password) async {
    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.loginMutation),
          variables: {
            'email': email,
            'password': password,
          },
        ),
      );

      if (result.hasException) {
        if (kDebugMode) {
          //print('Login error: ${result.exception}');
        }
        return null;
      }

      final data = result.data?['login'];
      if (data != null) {
        // Le backend retourne directement l'utilisateur, pas un objet AuthResponse
        final loggedUser = User.fromJson(data);
        user = loggedUser;
        
        // Générer un token temporaire (en attendant que le backend soit mis à jour)
        _accessToken = 'temp_token_${loggedUser.id}';
        
        // Sauvegarde des données d'authentification
        await _storageService.saveToken(_accessToken!);
        await _storageService.saveUserData(
          userId: user!.id,
          email: user!.email,
        );
        
        // Recréation du client avec le nouveau token
        _client = GraphQLConfig.createClient(token: _accessToken);
        
        return AuthResponse(
          accessToken: _accessToken!,
          user: loggedUser,
        );
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        //print('Login exception: $e');
      }
      return null;
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      if (kDebugMode) {
        print('🔍 Tentative d\'inscription pour: $email');
      }
      
      final result = await client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.registerMutation),
          variables: {
            'email': email,
            'password': password,
          },
        ),
      );
      
      if (result.hasException) {
        if (kDebugMode) {
          print('❌ Erreur d\'inscription: ${result.exception}');
          final exception = result.exception;
          
          // Vérifier si c'est une erreur de contrainte unique
          if (exception.toString().contains('Unique constraint') || 
              exception.toString().contains('duplicate key') ||
              exception.toString().contains('already exists')) {
            print('⚠️ Email déjà utilisé détecté');
            return null;
          }
        }
        return null;
      }

      final data = result.data?['createUser'];
      if (kDebugMode) {
        print('✅ Réponse d\'inscription: $data');
      }
      
      if (data != null) {
        final newUser = User.fromJson(data);
        if (kDebugMode) {
          print('✅ Utilisateur créé avec succès: ${newUser.email}');
        }
        return newUser;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception d\'inscription: $e');
        print('Type: ${e.runtimeType}');
      }
      return null;
    }
  }

  /// Authentification Google
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      if (kDebugMode) {
        print('🔍 Début de la connexion Google');
      }
      
      // Configuration Google Sign In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: '425980769579-dotq5kb13ocqgubm7l150d0ap08tmspm.apps.googleusercontent.com',
        scopes: ['email'],
      );
      
      // Connexion Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        if (kDebugMode) {
          print('❌ Connexion Google annulée par l\'utilisateur');
        }
        return null;
      }
      
      if (kDebugMode) {
        print('✅ Connexion Google réussie pour: ${googleUser.email}');
      }
      
      // Obtenir les détails d'authentification
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Créer les credentials Firebase
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Se connecter à Firebase
      final firebase_auth.UserCredential userCredential = 
          await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        final firebaseUser = userCredential.user!;
        
        if (kDebugMode) {
          print('🔥 Connexion Firebase réussie pour: ${firebaseUser.email}');
        }
        
        // Stratégie simplifiée: créer un utilisateur local temporaire
        // sans passer par le backend pour éviter les erreurs
        final tempUserId = 'google_${firebaseUser.uid}';
        final tempUser = User(
          id: tempUserId,
          email: firebaseUser.email!,
        );
        
        // Essayer de créer l'utilisateur dans le backend
        try {
          // Générer un mot de passe sécurisé
          final tempPassword = 'G00gl3_${firebaseUser.uid}_${DateTime.now().millisecondsSinceEpoch}';
          
          if (kDebugMode) {
            print('🔄 Tentative de création d\'utilisateur dans le backend...');
          }
          
          final result = await client.mutate(
            MutationOptions(
              document: gql(GraphQLQueries.findOrCreateUserMutation),
              variables: {
                'email': firebaseUser.email,
                'password': tempPassword,
              },
            ),
          );
          
          if (result.hasException) {
            if (kDebugMode) {
              print('⚠️ Erreur lors de la création (utilisateur existe peut-être): ${result.exception}');
            }
            
            // Essayer de se connecter avec un mot de passe par défaut
            final loginResult = await client.mutate(
              MutationOptions(
                document: gql(GraphQLQueries.loginMutation),
                variables: {
                  'email': firebaseUser.email,
                  'password': tempPassword,
                },
              ),
            );
            
            if (!loginResult.hasException) {
              final loginData = loginResult.data?['login'];
              if (loginData != null) {
                final backendUser = User.fromJson(loginData);
                user = backendUser;
                _accessToken = 'google_token_${backendUser.id}';
                
                if (kDebugMode) {
                  print('✅ Connexion backend réussie pour utilisateur existant');
                }
                
                await _saveUserData(backendUser);
                return AuthResponse(
                  accessToken: _accessToken!,
                  user: backendUser,
                );
              }
            }
          } else {
            // Utilisateur créé avec succès
            final data = result.data?['createUser'];
            if (data != null) {
              final backendUser = User.fromJson(data);
              user = backendUser;
              _accessToken = 'google_token_${backendUser.id}';
              
              if (kDebugMode) {
                print('✅ Utilisateur créé avec succès dans le backend');
              }
              
              await _saveUserData(backendUser);
              return AuthResponse(
                accessToken: _accessToken!,
                user: backendUser,
              );
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Erreur backend: $e');
          }
        }
        
        // Fallback: utiliser l'utilisateur temporaire si le backend échoue
        if (kDebugMode) {
          print('⚠️ Utilisation du mode fallback (utilisateur temporaire)');
        }
        
        user = tempUser;
        _accessToken = 'google_fallback_$tempUserId';
        
        await _saveUserData(tempUser);
        return AuthResponse(
          accessToken: _accessToken!,
          user: tempUser,
        );
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur générale Google Sign In: $e');
        print('Stack trace: ${StackTrace.current}');
      }
      return null;
    }
  }
  
  Future<void> _saveUserData(User userData) async {
    await _storageService.saveToken(_accessToken!);
    await _storageService.saveUserData(
      userId: userData.id,
      email: userData.email,
    );
    _client = GraphQLConfig.createClient(token: _accessToken);
  }

  Future<void> logout() async {
    // Déconnexion de Google Sign In
    try {
      await GoogleSignIn().signOut();
      await firebase_auth.FirebaseAuth.instance.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
    }
    
    // Nettoyage complet des données
    await _storageService.clearAll();
    user = null;
    _accessToken = null;
    _client = null;
    
    // Recréer un client sans token
    _client = GraphQLConfig.createClient(token: null);
  }

  bool isAuthenticated() {
    return user != null && _accessToken != null;
  }
}
