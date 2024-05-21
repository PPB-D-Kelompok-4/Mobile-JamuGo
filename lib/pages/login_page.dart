import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_text_fields/material_text_fields.dart';
import "package:material_text_fields/theme/material_text_field_theme.dart";
import "package:material_text_fields/utils/form_validation.dart";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void initState() {
    _passwordVisible = false;
    super.initState();
  }

  void showErrorSnackbar(BuildContext context, String errorCode) {
    final snackBar = SnackBar(
      content: Text('Error: $errorCode'),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void signUserIn() async {
    final BuildContext currentContext = context;
    showDialog(
      context: currentContext,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      Navigator.pop(currentContext);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(currentContext);
      showErrorSnackbar(currentContext, e.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              SizedBox(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60.0, left: 22),
                  child: Text(
                    'Sign-in.',
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
                          floatingLabelStyle: const TextStyle(color: Colors.black),
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
                        obscureText: !_passwordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            !_passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey[500],
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                        theme: BorderlessTextTheme(
                          radius: 0,
                          errorStyle: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              fontWeight: FontWeight.w700),
                          fillColor: Colors.transparent,
                          enabledColor: Colors.black,
                          focusedColor: Colors.black,
                          floatingLabelStyle: const TextStyle(color: Colors.black),
                          width: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Forget Password?',
                            style: TextStyle(
                                color: Colors.indigo[900],
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: MaterialButton(
                        onPressed: signUserIn,
                        minWidth: MediaQuery.of(context).size.width,
                        height: 55,
                        elevation: 2,
                        color: Colors.indigo[900],
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          "Sign in",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don/'t have an account?",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 2),
                        GestureDetector(
                          onTap: (){},
                          child: Text(
                            'Register',
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
