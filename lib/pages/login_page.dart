import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_text_fields/material_text_fields.dart';
import 'package:material_text_fields/theme/material_text_field_theme.dart';
import 'package:material_text_fields/utils/form_validation.dart';
import 'package:mobile_jamugo/api/auth/auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_jamugo/utils/secure_storage.dart';
import 'package:mobile_jamugo/utils/shared_preferences.dart';
import 'package:mobile_jamugo/widgets/submit_button.dart';

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

  void signUserIn() async {
    final BuildContext currentContext = context;
    showDialog(
      context: currentContext,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.green,
          ),
        );
      },
    );

    LoginResponse loginResponse = await AuthApi.login(
      email: emailController.text,
      password: passwordController.text,
    );

    Navigator.pop(currentContext);
    showToast(currentContext, loginResponse.message, loginResponse.isSuccess);

    if (loginResponse.isSuccess == true) {
      await SecureStorageUtil.writeSecureData(
          key: 'token', value: loginResponse.token!);
      CheckTokenResponse checkTokenResponse = await AuthApi.checkToken();
      await SharedPreferencesUtil.writeData(
          key: 'role', value: checkTokenResponse.role);
      await SharedPreferencesUtil.writeData(
          key: 'name', value: checkTokenResponse.name);
      GoRouter.of(context).go('/home');
    } else {
      GoRouter.of(context).refresh();
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
                  child: Row(
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
                      const Text(
                        'Sign-in.',
                        style: TextStyle(
                            fontSize: 35,
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
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
                            fontWeight: FontWeight.w700,
                          ),
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
                        keyboardType: TextInputType.visiblePassword,
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
                            fontWeight: FontWeight.w700,
                          ),
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
                    SubmitButton(onPressed: signUserIn, buttonText: 'Sign in'),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 2),
                        GestureDetector(
                          onTap: () {
                            GoRouter.of(context).go('/register');
                          },
                          child: const Text(
                            'Register',
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
