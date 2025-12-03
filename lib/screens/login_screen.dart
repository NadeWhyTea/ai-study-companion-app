import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:js' as js; // For JS interop
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      // Expose a global function that JS can call with the credential
      js.context['flutterWebSdkCallback'] = (String credential) async {
        try {
          print('Flutter received credential: $credential');
          final user =
          await AuthService().signInWithGoogle(idToken: credential);
          if (user != null && mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sign-in failed. Try again.')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign-in failed: $e')),
          );
        }
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Leave an empty transparent area where the HTML button sits
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SizedBox(
            width: 250,
            height: 50,
            child: const Text(
              " ", // invisible placeholder
              style: TextStyle(color: Colors.transparent),
            ),
          ),
        ),
      );
    }

    // Mobile UI
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Sign in with Google'),
          onPressed: () async {
            try {
              final user = await AuthService().signInWithGoogle();
              if (user != null && mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sign-in failed. Try again.')),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sign-in failed: $e')),
              );
            }
          },
        ),
      ),
    );
  }
}