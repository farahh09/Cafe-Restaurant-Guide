import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cafe_restaurant_guide/API/config.dart';
import 'package:http/http.dart' as http;
import 'package:cafe_restaurant_guide/Stores/stores.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

//Fetches all product names from the backend
final allProductsProvider = FutureProvider<List<String>>((ref) async {
  final response = await http.get(Uri.parse('$baseUrl/api/auth/products'));
  if (response.statusCode == 200) {
    return (json.decode(response.body)['products'] as List)
        .map((p) => p.toString())
        .toList();
  }
  throw Exception('Failed to load products');
});

//Stores the currently selected product, initialized as null (no product selected)
final selectedProductProvider = StateProvider<String?>((ref) => null);

//When a product is selected, it fetches a list of Store objects selling that product.
final searchResultsProvider = FutureProvider.autoDispose
    .family<List<Store>, String>((ref, product) async {
      if (product.isEmpty) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/search/product/$product'),
      );
      if (response.statusCode == 200) {
        return (json.decode(response.body)['restaurants'] as List)
            .map<Store>((json) => Store.fromJson(json))
            .toList();
      }
      throw Exception('Failed to load search results');
    });

//Tracks whether the current view is list or map.
final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.list);

enum ViewMode { list, map } //defines the two possible view modes.

class ProductSearchScreen extends ConsumerStatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  ConsumerState<ProductSearchScreen> createState() =>
      _ProductSearchScreenState();
}

class _ProductSearchScreenState extends ConsumerState<ProductSearchScreen> {
  Position? currentPosition;
  bool isLoading = true;
  bool isMapInitialized = false;
  final MapController mapController = MapController(); // Controls the map view

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  //Uses Geolocator to get current location with permission handling
  Future<void> _getCurrentLocation() async {
    try {
      // Check location permission
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Request permission if denied
        final request = await Geolocator.requestPermission();
        if (request == LocationPermission.denied ||
            request == LocationPermission.deniedForever) {
          setState(() => isLoading = false);
          return;
        }
      }

      // Get current position
      if (permission == LocationPermission.deniedForever) {
        setState(() => isLoading = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentPosition = position;
        isLoading = false;
      });
    } catch (e) {
      print("Error getting location: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(allProductsProvider);
    final selectedProduct = ref.watch(selectedProductProvider);
    final viewMode = ref.watch(viewModeProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Product Search',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w500,
            fontSize: 22,
          ),
        ),
        actions: [
          // Toggle between list and map view
          IconButton(
            icon: Icon(viewMode == ViewMode.list ? Icons.map : Icons.list),
            onPressed: () => ref.read(viewModeProvider.notifier).state =
                viewMode == ViewMode.list ? ViewMode.map : ViewMode.list,
            tooltip: viewMode == ViewMode.list
                ? 'Switch to Map View'
                : 'Switch to List View',
          ),
        ],
      ),
      body: Column(
        children: [
          // Product dropdown
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: productsAsync.when(
              data: (products) =>
                  _buildProductDropdown(products, selectedProduct),
              //Shows dropdown with products
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Error loading products: $error'),
            ),
          ),

          const Divider(thickness: 1),

          // Results area
          Expanded(
            child: selectedProduct != null
                ? _buildSearchResults(
                    selectedProduct,
                    viewMode,
                  ) //Shows search results if a product is selected
                : Center(
                    child: Text(
                      'Select a product to see available restaurants',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDropdown(List<String> products, String? selectedProduct) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.lightBlue.shade400),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(
            'Select a product',
            style: GoogleFonts.montserrat(color: Colors.grey),
          ),
          value: selectedProduct,
          items: products
              .map(
                (product) => DropdownMenuItem<String>(
                  value: product,
                  child: Text(product, style: GoogleFonts.montserrat()),
                ),
              )
              .toList(),
          onChanged: (value) {
            // When a product is selected
            ref.read(selectedProductProvider.notifier).state =
                value; //Updates the selectedProductProvider
            if (ref.read(viewModeProvider) == ViewMode.map) {
              //If in map view, resets the map initialization flag to trigger a refresh
              setState(() => isMapInitialized = false);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSearchResults(String productName, ViewMode viewMode) {
    final searchResultsAsync = ref.watch(searchResultsProvider(productName));

    return searchResultsAsync.when(
      data: (stores) {
        if (stores.isEmpty) {
          return Center(
            child: Text(
              'No restaurants found for "$productName"',
              style: GoogleFonts.montserrat(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return viewMode ==
                ViewMode
                    .list //If stores found, builds either list or map view based on current viewMode
            ? _buildListView(stores)
            : _buildMapView(stores);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Error: $error',
          style: GoogleFonts.montserrat(color: Colors.red),
        ),
      ),
    );
  }

  //results, a scrollable list of store cards
  Widget _buildListView(List<Store> stores) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: stores.length,
      itemBuilder: (_, index) {
        final store = stores[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () => _showStoreDetails(context, store),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(store.logoPath),
                    radius: 30,
                    backgroundColor: Colors.transparent,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.name,
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          store.description,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapView(List<Store> stores) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (currentPosition == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Location access is required for map view',
              style: GoogleFonts.montserrat(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: const Text('Grant Location Permission'),
            ),
          ],
        ),
      );
    }

    // Calculate center position
    LatLng centerPosition = stores.isNotEmpty
        ? LatLng(
            stores.map((s) => s.latitude).reduce((a, b) => a + b) /
                stores.length,
            stores.map((s) => s.longitude).reduce((a, b) => a + b) /
                stores.length,
          )
        : (currentPosition != null
              ? LatLng(currentPosition!.latitude, currentPosition!.longitude)
              : LatLng(30.0444, 31.2357)); // Cairo default

    // Mark map as initialized after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isMapInitialized) setState(() => isMapInitialized = true);
    });

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: centerPosition,
        zoom: 12.0,
        interactiveFlags: InteractiveFlag.all,
        onMapReady: () {
          // Fit bounds to show all markers
          if (stores.length > 1) {
            Future.delayed(const Duration(milliseconds: 300), () {
              mapController.fitBounds(
                LatLngBounds.fromPoints(
                  stores.map((s) => LatLng(s.latitude, s.longitude)).toList(),
                ),
                options: const FitBoundsOptions(padding: EdgeInsets.all(50.0)),
              );
            });
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.mobile_project',
        ),
        MarkerLayer(
          markers: [
            // User's current location marker
            if (currentPosition != null)
              Marker(
                point: LatLng(
                  currentPosition!.latitude,
                  currentPosition!.longitude,
                ),
                width: 30,
                height: 30,
                builder: (_) => Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.7),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),

            // Store markers
            ...stores.map(
              (store) => Marker(
                width: 40,
                height: 40,
                point: LatLng(store.latitude, store.longitude),
                builder: (_) => GestureDetector(
                  onTap: () => _showStoreDetails(context, store),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(store.logoPath, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showStoreDetails(BuildContext context, Store store) {
    // Calculate distance between user and store if location is available
    final distance = currentPosition != null
        ? Geolocator.distanceBetween(
            currentPosition!.latitude,
            currentPosition!.longitude,
            store.latitude,
            store.longitude,
          )
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.75,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Store header
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(store.logoPath),
                      radius: 30,
                      backgroundColor: Colors.transparent,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        store.name,
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  store.description,
                  style: GoogleFonts.montserrat(fontSize: 16),
                ),
                const SizedBox(height: 16),

                // Distance information
                if (distance != null) _buildDistanceInfo(distance),
                const SizedBox(height: 24),

                // Get directions button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _launchMaps(store.latitude, store.longitude),
                    icon: const Icon(Icons.directions),
                    label: Text(
                      'Get Directions',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.lightBlue.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceInfo(double distance) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            'Distance: ${(distance / 1000).toStringAsFixed(2)} km',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchMaps(double lat, double lng) async {
    //Creates a Google Maps URL with directions to the store coordinates
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open maps')));
    }
  }
}
