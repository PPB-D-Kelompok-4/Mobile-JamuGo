import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jamugo/utils/secure_storage.dart';
import 'package:jamugo/components/card_exit.dart';

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
    final token = await SecureStorageUtil.readSecureData(key: 'token');
    if (token != null) {
      GoRouter.of(context).go('/home');
    }
    return token ?? '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ModalRoute.of(context)?.addScopedWillPopCallback(_onWillPop);
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => CardExit(
            onConfirm: () {
              GoRouter.of(context).pop(true);
            },
            onCancel: () {
              GoRouter.of(context).pop(false);
            },
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    ModalRoute.of(context)?.removeScopedWillPopCallback(_onWillPop);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Spacer(flex: 1),
            Image.asset(
              'assets/images/jamugologo.png',
              height: MediaQuery.of(context).size.height * 0.3,
            ),
            const SizedBox(height: 20),
            const Text(
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
            const SizedBox(height: 10),
            const Text(
              'Kesehatan Tradisional dalam Genggaman Anda.',
              style: TextStyle(
                fontSize: 20,
                color: Color.fromRGBO(0, 0, 0, 1),
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 2),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      GoRouter.of(context).go('/login');
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      backgroundColor: const Color.fromRGBO(94, 185, 120, 1),
                      side: const BorderSide(
                        color: Color.fromRGBO(94, 185, 120, 1),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: Color.fromRGBO(94, 185, 120, 1),
                      ),
                    ),
                    onPressed: () {
                      GoRouter.of(context).go('/register');
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: Color.fromRGBO(94, 185, 120, 1),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
