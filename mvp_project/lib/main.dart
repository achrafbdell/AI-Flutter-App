import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mvp_project/views/cart.dart';
import 'package:mvp_project/views/profile.dart';
import 'package:mvp_project/views/home.dart';
import 'package:mvp_project/auth/login.dart';
import 'services/firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MVP',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/panier': (context) => PanierPage(),
        '/profile': (context) => ProfilePage()
      },
    );
  }
}
