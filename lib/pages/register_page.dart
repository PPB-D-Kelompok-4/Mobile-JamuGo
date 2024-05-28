import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
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
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void showToast(BuildContext context, String message, bool isSuccess) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
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
        final RegisterResponse response = await AuthApi.register(
          email: emailController.text,
          password: passwordController.text,
          name: nameController.text,
          address: addressController.text,
        );

        showToast(context, response.message, response.isSuccess);
        GoRouter.of(context).go('/login');
      } else {
        showToast(context, "Passwords do not match", false);
      }

      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      showToast(context, e.toString(), false);
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
              const SizedBox(
                child: Padding(
                  padding: EdgeInsets.only(top: 60.0, left: 22),
                  child: Text(
                    'Sign-up.',
                    style: TextStyle(
                        fontSize: 35,
                        color: Colors.green,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 150.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: MaterialTextField(
                        keyboardType: TextInputType.emailAddress,
                        labelText: "Name",
                        textInputAction: TextInputAction.next,
                        controller: nameController,
                        validator: FormValidation.requiredTextField,
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
                        labelText: "Address",
                        textInputAction: TextInputAction.next,
                        controller: addressController,
                        validator: FormValidation.requiredTextField,
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
                        color: Colors.green,
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
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.green,
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
