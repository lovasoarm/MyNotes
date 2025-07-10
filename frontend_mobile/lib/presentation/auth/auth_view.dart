// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:frontend_mobile/core/constants/colors.dart';
import 'package:frontend_mobile/presentation/widgets/auth_widget.dart';
import 'package:frontend_mobile/presentation/widgets/animation_widget.dart';
import 'package:frontend_mobile/view_models/auth/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  _AuthViewState createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  bool isLogin = true;
  

  void toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewmodel>(
      builder: (context, authViewModel, child) {
        // Redirection automatique si utilisateur déjà connecté et pas en cours de chargement
        if (authViewModel.isAuthenticated && !authViewModel.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/home');
          });
        }
        
        return Scaffold(
          backgroundColor: AppColors.background,
          body: AnimationWidget.fadeAndScale(
            duration: const Duration(milliseconds: 800),
            child: AuthWidget(
              isLogin: isLogin,
              onLogin: toggleAuthMode,
            ),
          ),
        );
      },
    );
  }
}