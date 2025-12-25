import 'package:cafe_restaurant_guide/screens/product_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../Stores/stores.dart';
import '../screens/login_screen.dart';
import '../screens/product_search_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../API/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Store>> fetchRestaurants() async {
  final url = Uri.parse('$baseUrl/api/auth/restaurants');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    final List storesJson = body['stores'];
    return storesJson.map((json) => Store.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load restaurants');
  }
}
// Navigation state provider to manage the current screen index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  static const routeName = 'HomeScreen';
  final String userEmail;

  const HomeScreen({super.key, required this.userEmail});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final List<Widget> screens = [ // Define the list of screens
      _buildHomeScreen(context),
      ProductSearchScreen(),
    ];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.lightBlue.shade800,
        unselectedItemColor: Colors.grey,
        onTap: (index) => ref.read(navigationIndexProvider.notifier).state = index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Restaurants'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        ],
      ),
    );
  }


  Widget _buildHomeScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Restaurants',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w500,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Store>>(
        future: fetchRestaurants(), // Fetch from API
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No restaurants available'));
          }
          final restaurants = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: restaurants.length,
            itemBuilder: (context, index) {
              final store = restaurants[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Image.asset(
                    store.logoPath,
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                  ),
                  title: Text(store.name),
                  subtitle: Text(store.description),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListScreen(store: store),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

}