import 'dart:convert';
import 'package:cafe_restaurant_guide/screens/login_screen.dart';
import 'package:cafe_restaurant_guide/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'API/config.dart';
import 'Stores/stores.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<Store> stores = [
    Store(
      name: 'Cilantro',
      logoPath: 'assets/images/cafe.png',
      products: ['Coffee', 'Croissant', 'Sandwich', 'Cake'],
      latitude: 30.055444119008964,
      longitude: 31.201470553159186,
      description:
          'A cozy café offering artisan coffee and fresh pastries in a modern setting.',
    ),
    Store(
      name: 'Wendy\'s',
      logoPath: 'assets/images/wendys.png',
      products: ['Burger', 'Fries', 'Cola', 'Chicken'],
      latitude: 30.084148645310602,
      longitude: 31.332444870858474,
      description:
          'Delight in the freshest burger dishes with american-inspired ambiance.',
    ),
    Store(
      name: 'Tikka',
      logoPath: 'assets/images/grill.png',
      products: ['Kofta', 'Grilled Chicken', 'Salad', 'Rice'],
      latitude: 30.05533586846566,
      longitude: 31.204515891626663,
      description:
          'Every grill tells a story.',
    ),
    Store(
      name: 'ASIAN Corner',
      logoPath: 'assets/images/asian.png',
      products: ['Noodles', 'Rice', 'Broth', 'Dumplings'],
      latitude: 29.967918501415898,
      longitude: 31.26723202765107,
      description:
          'Asian fusion delights served sizzling hot — bold flavors, bright vibes.',
    ),
    Store(
      name: 'Chicken Workx',
      logoPath: 'assets/images/fast_food.png',
      products: ['Burger', 'Fries', 'Milkshake', 'Fried Chicken'],
      latitude: 30.00860383467504,
      longitude: 30.99573803047055,
      description:
          'Crispy on the outside, juicy on the inside – our fried chicken is seasoned to perfection and fried golden brown',
    ),
    Store(
      name: 'Koueider',
      logoPath: 'assets/images/ice_cream.png',
      products: ['Chocolate Ice Cream', 'Mango Ice Cream', 'Vanilla Ice Cream', 'Strawberry Ice Cream'],
      latitude: 30.02887009900242,
      longitude: 31.013325213118478,
      description:
          'Experience the best of Egyptian ice cream with Koueider.',
    ),
  ];
  final url = Uri.parse('$baseUrl/api/auth/restaurants');
  final _ = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(stores.map((s) => s.toJson()).toList()),
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (context) => LoginScreen(),
        SignupScreen.routeName: (context) => SignupScreen(),
      },
    );
  }
}
