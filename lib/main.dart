import 'package:flutter/material.dart';
import 'package:unsaid_feelings/pages/auth_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:unsaid_feelings/themes/darl_theme.dart';
import 'package:unsaid_feelings/themes/light_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: AuthPage(),
    );
  }
}
