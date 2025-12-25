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
      name: 'Wadi El Nile',
      logoPath: 'assets/images/sea.png',
      products: ['Shrimp', 'Fish', 'Salad', 'Sea Boil'],
      latitude: 30.06461304154986,
      longitude: 31.20026723543947,
      description:
          'Delight in the freshest seafood dishes with ocean-inspired ambiance.',
    ),
    Store(
      name: 'Papa Jones',
      logoPath: 'assets/images/pizza.png',
      products: ['Pizza', 'Margherita', 'Salad', 'Garlic Bread'],
      latitude: 30.092652795597267,
      longitude: 31.308577647427896,
      description:
          'YWhere wood-fired pizza meets classic Italian flavors. Every slice tells a story.',
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
      logoPath: 'assets/images/fast.png',
      products: ['Burger', 'Fries', 'Milkshake', 'Fried Chicken'],
      latitude: 30.00860383467504,
      longitude: 30.99573803047055,
      description:
          'Crispy on the outside, juicy on the inside – our fried chicken is seasoned to perfection and fried golden brown',
    ),
    Store(
      name: 'Koshary El Basha',
      logoPath: 'assets/images/koshary.png',
      products: ['King Koshary', 'The Double', 'Toast Bread', 'Super Koshary'],
      latitude: 29.995424467357335,
      longitude: 31.209954971164912,
      description:
          'Experience the heart of Egyptian street food with our delicious Koshary.',
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
