import 'package:flutter/material.dart';
import 'package:unsaid_feelings/pages/login_page.dart';
import 'package:unsaid_feelings/pages/register_page.dart';

class LoginPageOrRegister extends StatefulWidget {
  const LoginPageOrRegister({super.key});

  @override
  State<LoginPageOrRegister> createState() => _LoginPageOrRegisterState();
}

class _LoginPageOrRegisterState extends State<LoginPageOrRegister> {
  bool showLoginPage = true;
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        onTap: togglePages,
      );
    } else {
      return RegisterPage(
        onTap: togglePages,
      );
    }
  }
}
