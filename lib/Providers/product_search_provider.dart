import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final selectedProductProvider = StateProvider<String?>((ref) => null);//Holds the currently selected product name

final searchResultsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final product = ref.watch(selectedProductProvider); //gets the current product
  if (product == null) return [];

  final response = await http.post(
    Uri.parse("http://<YOUR-IP>:5001/api/auth/search_by_product"),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'product': product}),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body)['results'];
  } else {
    throw Exception('No results found');
  }
});
