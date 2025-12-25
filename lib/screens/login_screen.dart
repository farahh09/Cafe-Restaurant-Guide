import 'package:cafe_restaurant_guide/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cafe_restaurant_guide/components/custom_button.dart';
import 'package:cafe_restaurant_guide/components/custom_textfield.dart';
import 'package:cafe_restaurant_guide/API/config.dart';
import 'package:cafe_restaurant_guide/Providers/signup_provider.dart';
import 'package:cafe_restaurant_guide/screens/home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends ConsumerStatefulWidget {
  static const String routeName = 'LoginScreen';

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? emailError, passError;

  void login() async {
    if (_formKey.currentState!.validate()) {
      final email = ref.read(emailControllerProvider).text.trim();
      final password = ref.read(passwordControllerProvider).text.trim();

      final url = Uri.parse('$baseUrl/api/auth/login'); //server url
      final response = await http.post(
        //getting student data
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final responseBody = jsonDecode(
        response.body,
      ); // request response's return
      final errors = responseBody['errors'];

      setState(() {
        emailError = errors?['email'];
        passError = errors?['password'];
      });
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(userEmail: email)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailController = ref.watch(emailControllerProvider);
    final passwordController = ref.watch(passwordControllerProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue.shade800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Hi! Welcome back, you've been missed",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 20),
                CustomTextField(
                  text_: "Email",
                  controller: emailController,
                  hintText: "Enter Your Email",
                  obscureText: false,
                  icon: Icons.email,
                  errorMessage: emailError,
                ),
                SizedBox(height: 15),
                CustomTextField(
                  text_: "Password",
                  controller: passwordController,
                  hintText: "Enter Your Password",
                  obscureText: true,
                  icon: Icons.lock,
                  errorMessage: passError,
                ),

                SizedBox(height: 10),
                Align(alignment: Alignment.centerRight),
                SizedBox(height: 10),
                CustomButton(textButton: "Log In", onTap: login),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignupScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
