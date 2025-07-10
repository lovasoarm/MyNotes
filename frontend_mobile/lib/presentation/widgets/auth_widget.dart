// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:frontend_mobile/core/constants/colors.dart';
import 'package:frontend_mobile/view_models/auth/auth_viewmodel.dart';
import 'package:frontend_mobile/state_management/state_widgets.dart';
import 'package:provider/provider.dart';

class AuthWidget extends StatefulWidget {
  final bool isLogin;
  final VoidCallback? onLogin;
  
  const AuthWidget({
    super.key,
    required this.isLogin,
    this.onLogin,
  });

  @override
  _AuthWidgetState createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
 
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuthAction(AuthViewmodel authViewModel) async {
    authViewModel.clearMessages();
    
    if (widget.isLogin) {
      await _handleLogin(authViewModel);
    } else {
      await _handleRegistration(authViewModel);
    }
  }

  Future<void> _handleLogin(AuthViewmodel authViewModel) async {
    final result = await authViewModel.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    
    if (!mounted) return;
    
    if (result.success) {
      SnackBarUtils.showSuccess(context, result.message);
      Navigator.pushReplacementNamed(
        context, 
        '/home',
        arguments: {'username': _usernameController.text.trim()},
      );
    } else {
      SnackBarUtils.showError(context, result.message);
    }
  }

  Future<void> _handleRegistration(AuthViewmodel authViewModel) async {
    final result = await authViewModel.register(
      _emailController.text.trim(),
      _passwordController.text,
      _confirmPasswordController.text,
    );
    
    if (!mounted) return;
    
    if (result.success) {
      SnackBarUtils.showSuccess(context, result.message);
      await _handleLoginAfterRegistration(authViewModel);
    } else {
      SnackBarUtils.showError(context, result.message);
    }
  }

  Future<void> _handleLoginAfterRegistration(AuthViewmodel authViewModel) async {
    final loginResult = await authViewModel.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    
    if (!mounted) return;
    
    if (loginResult.success) {
      Navigator.pushReplacementNamed(
        context, 
        '/home',
        arguments: {'username': _usernameController.text.trim()},
      );
    } else {
      SnackBarUtils.showError(context, loginResult.message);
    }
  }

  Future<void> _handleGoogleSignIn(AuthViewmodel authViewModel) async {
    authViewModel.clearMessages();
    
    final result = await authViewModel.signInWithGoogle();
    
    if (!mounted) return;
    
    if (result.success) {
      SnackBarUtils.showSuccess(context, result.message);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      SnackBarUtils.showError(context, result.message);
    }
  }

  Widget _buildGoogleSignInButton(AuthViewmodel authViewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 1,
        ),
        onPressed: authViewModel.isLoading ? null : () => _handleGoogleSignIn(authViewModel),
        child: authViewModel.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'docs/png/google.png',
                    height: 20,
                    width: 20,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Continuer avec Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAuthToggleButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.isLogin 
              ? 'Vous n\'avez pas de compte ?' 
              : 'Vous avez déjà un compte ?',
        ),
        TextButton(
          onPressed: widget.onLogin,
          child: Text(
            widget.isLogin ? 'S\'inscrire' : 'Se connecter',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.black.withAlpha(100)),
          icon: const Icon(Icons.lock, color: AppColors.primary),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: AppColors.secondary,
            ),
            onPressed: onToggleVisibility,
          ),
          filled: true,
          fillColor: Colors.white,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelStyle: TextStyle(color: Colors.black.withAlpha(100)),
          labelText: labelText,
          icon: Icon(icon, color: AppColors.primary),
          filled: true,
          fillColor: Colors.white,
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (!widget.isLogin) const SizedBox(height: 10),
              Icon(Icons.note_add, size: 100, color: AppColors.primary),
              const SizedBox(height: 20),
              const Text(
                'Bienvenue sur Mynotes',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontFamily: 'DancingScript',
                ),
              ),
              const SizedBox(height: 50),
              Text(
                widget.isLogin ? 'Se connecter' : 'Créer un compte',
                style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Form(
                child: Column(
                  children: [
                    if (!widget.isLogin)
                      _buildTextField(
                        controller: _usernameController,
                        labelText: 'Nom de l\'utilisateur',
                        icon: Icons.person,
                      ),
                    _buildTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      icon: Icons.email,
                    ),
                    _buildPasswordField(
                      controller: _passwordController,
                      labelText: 'Mot de passe',
                      obscureText: _obscurePassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    if (!widget.isLogin)
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        labelText: 'Confirmer mot de passe',
                        obscureText: _obscureConfirmPassword,
                        onToggleVisibility: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    const SizedBox(height: 30),
                    Consumer<AuthViewmodel>(
                      builder: (context, authViewModel, child) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AppColors.background,
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 75, 
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: authViewModel.isLoading 
                              ? null 
                              : () => _handleAuthAction(authViewModel),
                          child: authViewModel.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.background,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(widget.isLogin ? 'Se connecter' : 'S\'inscrire'),
                        );
                      },
                    ),
                    
                    if (widget.isLogin) ...[
                      const SizedBox(height: 20),
                      Consumer<AuthViewmodel>(
                        builder: (context, authViewModel, _) => 
                            _buildGoogleSignInButton(authViewModel),
                      ),
                      SizedBox(height:20),
                      // Divider avec "ou"
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 30),
                              child: Divider(
                                color: Colors.grey.shade400,
                                thickness: 1,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'ou',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 30),
                              child: Divider(
                                color: Colors.grey.shade400,
                                thickness: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 30),
                    _buildAuthToggleButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}