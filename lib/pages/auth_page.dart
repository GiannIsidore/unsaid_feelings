import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unsaid_feelings/pages/home_page.dart';
import 'package:unsaid_feelings/pages/login_or_register.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print("logged in");
            return HomePage();
          } else {
            print(" not logged in");
            return LoginPageOrRegister();
          }
        },
      ),
    );
  }
}
