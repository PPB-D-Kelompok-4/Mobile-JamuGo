import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_jamugo/utils/secure_storage.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    getToken();
  }

  Future<String> getToken() async {
    final token = await SecureStorage.readSecureData(key: 'token');
    if (token != null) {
      GoRouter.of(context).go('/home');
    }
    return token ?? '';
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Image.asset(
                'assets/images/jamugologo.png',
                height: height * 0.5,
              ),
              const Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'JamuGO',
                    style: TextStyle(
                      fontSize: 60,
                      color: Color.fromRGBO(94, 185, 120, 1),
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.black,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Kesehatan Tradisional dalam Genggaman Anda.',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromRGBO(0, 0, 0, 1),
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 200),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        GoRouter.of(context).go('/login');
                      },
                      style: OutlinedButton.styleFrom(
                        shape: const RoundedRectangleBorder(),
                        backgroundColor: const Color.fromRGBO(94, 185, 120, 1),
                        side: const BorderSide(
                            color: Color.fromRGBO(94, 185, 120, 1)),
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.black),
                        shape: const RoundedRectangleBorder(),
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                      ),
                      onPressed: () {
                        GoRouter.of(context).go('/register');
                      },
                      child: const Text(
                        'Register',
                        style:
                            TextStyle(color: Color.fromRGBO(94, 185, 120, 1)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
