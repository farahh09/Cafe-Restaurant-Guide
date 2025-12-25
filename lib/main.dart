import 'package:cafe_restaurant_guide/screens/home_screen.dart';
import 'package:cafe_restaurant_guide/screens/login_screen.dart';
import 'package:cafe_restaurant_guide/screens/signup_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName : (context) => LoginScreen(),
        SignupScreen.routeName : (context) => SignupScreen(),
      },
    );
  }
}

