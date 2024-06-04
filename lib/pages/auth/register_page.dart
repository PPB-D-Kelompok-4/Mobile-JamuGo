import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';
import 'package:material_text_fields/utils/form_validation.dart';
import 'package:jamugo/api/auth/auth.dart';
import 'package:jamugo/utils/secure_storage.dart';
import 'package:jamugo/widgets/submit_button.dart';

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
    getToken();
  }

  Future<String> getToken() async {
    final token = await SecureStorageUtil.readSecureData(key: 'token');
    if (token != null) {
      GoRouter.of(context).go('/home');
    }
    return token ?? '';
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
          child: CircularProgressIndicator(color: Colors.green),
        );
      },
    );

    if (passwordController.text == confirmPasswordController.text) {
      final RegisterResponse response = await AuthApi.register(
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text,
        address: addressController.text,
      );
      Navigator.pop(context);
      showToast(context, response.message, response.isSuccess);
      if (response.isSuccess == true) {
        GoRouter.of(context).go('/login');
      } else {
        GoRouter.of(context).refresh();
      }
    } else {
      showToast(context, "Passwords do not match", false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            GoRouter.of(context).go('/landing');
                          },
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Sign-up',
                          style: TextStyle(
                            fontSize: 35,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 50, horizontal: 20),
                      child: Column(
                        children: [
                          MaterialTextField(
                            keyboardType: TextInputType.name,
                            labelText: "Name",
                            textInputAction: TextInputAction.next,
                            controller: nameController,
                            validator: FormValidation.requiredTextField,
                            theme: BorderlessTextTheme(
                              radius: 10,
                              errorStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                              ),
                              fillColor: Colors.white,
                              enabledColor: Colors.green,
                              focusedColor: Colors.green,
                              floatingLabelStyle:
                                  const TextStyle(color: Colors.green),
                              width: 2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          MaterialTextField(
                            keyboardType: TextInputType.streetAddress,
                            labelText: "Address",
                            textInputAction: TextInputAction.next,
                            controller: addressController,
                            validator: FormValidation.requiredTextField,
                            theme: BorderlessTextTheme(
                              radius: 10,
                              errorStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                              ),
                              fillColor: Colors.white,
                              enabledColor: Colors.green,
                              focusedColor: Colors.green,
                              floatingLabelStyle:
                                  const TextStyle(color: Colors.green),
                              width: 2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          MaterialTextField(
                            keyboardType: TextInputType.emailAddress,
                            labelText: "Email",
                            textInputAction: TextInputAction.next,
                            controller: emailController,
                            validator: FormValidation.emailTextField,
                            theme: BorderlessTextTheme(
                              radius: 10,
                              errorStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                              ),
                              fillColor: Colors.white,
                              enabledColor: Colors.green,
                              focusedColor: Colors.green,
                              floatingLabelStyle:
                                  const TextStyle(color: Colors.green),
                              width: 2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          MaterialTextField(
                            keyboardType: TextInputType.visiblePassword,
                            labelText: "Password",
                            textInputAction: TextInputAction.next,
                            controller: passwordController,
                            validator: FormValidation.requiredTextField,
                            obscureText: true,
                            theme: BorderlessTextTheme(
                              radius: 10,
                              errorStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                              ),
                              fillColor: Colors.white,
                              enabledColor: Colors.green,
                              focusedColor: Colors.green,
                              floatingLabelStyle:
                                  const TextStyle(color: Colors.green),
                              width: 2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          MaterialTextField(
                            keyboardType: TextInputType.visiblePassword,
                            labelText: "Confirm Password",
                            textInputAction: TextInputAction.done,
                            controller: confirmPasswordController,
                            validator: FormValidation.requiredTextField,
                            obscureText: true,
                            theme: BorderlessTextTheme(
                              radius: 10,
                              errorStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                              ),
                              fillColor: Colors.white,
                              enabledColor: Colors.green,
                              focusedColor: Colors.green,
                              floatingLabelStyle:
                                  const TextStyle(color: Colors.green),
                              width: 2,
                            ),
                          ),
                          const SizedBox(height: 40),
                          SubmitButton(onPressed: signUserUp, buttonText: 'Sign up'),
                        ],
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
