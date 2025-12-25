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
        backgroundColor: Colors.white,
        currentIndex: currentIndex,
        selectedItemColor: Colors.lightBlue.shade800,
        unselectedItemColor: Colors.grey,
        onTap: (index) => ref.read(navigationIndexProvider.notifier).state = index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favourites'),

        ],
      ),
    );
  }


  Widget _buildHomeScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                width: 355,
                height: 205,
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
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductListScreen(store: store),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  child: Image.asset(store.logoPath, height: 130,width: double.infinity,fit: BoxFit.fitWidth, errorBuilder: (context, error, stackTrace) => const Icon(Icons.image,size: 150,),)),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Icon(Icons.favorite_border, size: 25, color: Colors.white),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 8),
                            child: Text(store.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 5),
                            child: Text(store.description, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              );
            },
          );
        },
      ),
    );
  }

}