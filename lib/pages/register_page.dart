import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_jamugo/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_text_fields/material_text_fields.dart';
import "package:material_text_fields/theme/material_text_field_theme.dart";
import "package:material_text_fields/utils/form_validation.dart";
import "package:mobile_jamugo/api/auth.dart";

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void signUserUp() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      if (passwordController.text == confirmPasswordController.text) {
        await AuthApi.register(
          email: emailController.text,
          password: passwordController.text,
          name: 'Helmi',
          address: 'Informatika',
        );

        GoRouter.of(context).go('/home');
        print("user registered");
      } else {
        print("password don't match");
      }

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      print("auth error: " + e.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              SizedBox(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60.0, left: 22),
                  child: Text(
                    'Sign-up.',
                    style: TextStyle(
                        fontSize: 35,
                        color: Colors.indigo[900],
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 250.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: MaterialTextField(
                        keyboardType: TextInputType.emailAddress,
                        labelText: "Email",
                        textInputAction: TextInputAction.next,
                        controller: emailController,
                        validator: FormValidation.emailTextField,
                        theme: BorderlessTextTheme(
                          radius: 0,
                          errorStyle: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              fontWeight: FontWeight.w700),
                          fillColor: Colors.transparent,
                          enabledColor: Colors.black,
                          focusedColor: Colors.black,
                          floatingLabelStyle:
                              const TextStyle(color: Colors.black),
                          width: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: MaterialTextField(
                        keyboardType: TextInputType.emailAddress,
                        labelText: "Password",
                        textInputAction: TextInputAction.done,
                        controller: passwordController,
                        validator: FormValidation.requiredTextField,
                        obscureText: true,
                        theme: BorderlessTextTheme(
                          radius: 0,
                          errorStyle: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              fontWeight: FontWeight.w700),
                          fillColor: Colors.transparent,
                          enabledColor: Colors.black,
                          focusedColor: Colors.black,
                          floatingLabelStyle:
                              const TextStyle(color: Colors.black),
                          width: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: MaterialTextField(
                        keyboardType: TextInputType.emailAddress,
                        labelText: "Confirm Password",
                        textInputAction: TextInputAction.done,
                        controller: confirmPasswordController,
                        validator: FormValidation.requiredTextField,
                        obscureText: true,
                        theme: BorderlessTextTheme(
                          radius: 0,
                          errorStyle: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              fontWeight: FontWeight.w700),
                          fillColor: Colors.transparent,
                          enabledColor: Colors.black,
                          focusedColor: Colors.black,
                          floatingLabelStyle:
                              const TextStyle(color: Colors.black),
                          width: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: MaterialButton(
                        onPressed: signUserUp,
                        minWidth: MediaQuery.of(context).size.width,
                        height: 55,
                        elevation: 2,
                        color: Colors.indigo[900],
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          "Sign up",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 2),
                        GestureDetector(
                          onTap: () {
                            GoRouter.of(context).go('/login');
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.indigo[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
