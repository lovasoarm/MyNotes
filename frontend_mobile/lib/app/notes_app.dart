import 'package:flutter/material.dart';
import 'package:frontend_mobile/app/routes.dart';
import 'package:frontend_mobile/core/constants/colors.dart';
import 'package:frontend_mobile/presentation/auth/auth_view.dart';
import 'package:frontend_mobile/presentation/home/homeview.dart';

class Notesapp extends StatelessWidget {
const Notesapp({ super.key });

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: AppColors.background,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.auth,
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case AppRoutes.auth:
            return MaterialPageRoute(builder: (_) => const AuthView());
        
          case AppRoutes.home:
            return MaterialPageRoute(builder: (_) => const Homeview()); 

         
            default:
            return MaterialPageRoute(builder: (_) => const AuthView());
        }
      },
    );
  }
}