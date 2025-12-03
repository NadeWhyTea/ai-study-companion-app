import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart';
import 'dart:html' as html; // for web fullscreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Force fullscreen layout on mobile
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // On web, request fullscreen on page load
  if (kIsWeb) {
    html.document.documentElement?.requestFullscreen();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Study Companion',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
