class Store {
  final String name;
  final String description;
  final String logoPath;
  final List<String> products;
  final double latitude;
  final double longitude;


  Store({

    required this.name,
    required this.description,
    required this.logoPath,
    required this.products,
    required this.latitude,
    required this.longitude,

  });

  factory Store.fromJson(Map<String, dynamic> json) {// creates a store object from a json map
    var productsList = <String>[];
    //check if the products key exists in the json map. If it does, convert its value to a List of strings
    if (json['products'] != null) {
      productsList = List<String>.from(json['products']);
    }
    return Store(
      name: json['name'],
      description: json['description'],
      logoPath: json['logoPath'],
      products: productsList,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() { //converts a store object back to a json map
  return {
      'name': name,
      'description': description,
      'logoPath': logoPath,
      'products': products,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
