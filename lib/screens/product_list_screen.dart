import 'package:flutter/material.dart';

import '../Stores/stores.dart';

class ProductListScreen extends StatefulWidget {
  final Store store;
  const ProductListScreen({super.key, required this.store});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
