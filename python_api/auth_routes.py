from flask import Blueprint, request, jsonify
import re

auth_bp = Blueprint('auth', __name__)
users = [{
    'name': 'Farah Hany',
    'email': 'farahh@gmail.com',
    'password': 'farahhany1',
    'gender': 'female',
    'level': '4'
}]
restaurantsData = []


@auth_bp.route('/signup', methods=['POST'])
def signup():
    data = request.json
    errors = {}

    # Required fields
    name = data.get('name')
    email = data.get('email')
    password = data.get('password')
    confirm_password = data.get('confirm_password')

    # Optional fields
    gender = data.get('gender')
    level = data.get('level')

    if not name:
        errors['name'] = 'Name is required'

    if not email:
        errors['email'] = 'Email is required'
    elif not re.match(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$", email):
        errors['email'] = 'Invalid email format'

    if not password:
        errors['password'] = 'Password is required'
    elif len(password) < 8:
        errors['password'] = 'Must be at least 8 characters'

    if not confirm_password:
        errors['confirm_password'] = 'Confirming password is required'
    elif confirm_password != password:
        errors['confirm_password'] = 'Passwords do not match'

    existing_user = next((u for u in users if u['email'] == email), None)
    if existing_user:
        return jsonify({'errors': {'email': 'Email registered. Please login.'}}), 400

    if errors:
        return jsonify({'errors': errors}), 400

    # Proceed if no errors
    user = {
        'name': name,
        'gender': gender,
        'email': email,
        'level': level,
        'password': password,
    }
    users.append(user)
    return jsonify({'message': 'Signup successful', 'user': user}), 201


@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    password = data.get('password')

    errors = {}

    if not email:
        errors['email'] = 'Email is required'

    # Find user by email
    user = next((u for u in users if u['email'] == email), None)

    if not user:
        return jsonify({'errors': {'email': 'Email not found. Please sign up.'}}), 400

    if not password:
        errors['password'] = 'Password is required'

    if errors:
        return jsonify({'errors': errors}), 400

    elif user['password'] != password:
        return jsonify({'errors': {'password': 'Incorrect password'}}), 400

    return jsonify({'message': 'Login successful', 'user': user}), 200


@auth_bp.route('/restaurants', methods=['GET', 'POST'])
def restaurants():
    if request.method == 'POST':
        data = request.get_json()
        for item in data:
            exists = any(r['name'] == item['name'] for r in restaurantsData)
            if not exists:
                restaurant = {
                    'name': item['name'],
                    'description': item['description'],
                    'logoPath': item['logoPath'],
                    'products': item['products'],
                    'latitude': item['latitude'],
                    'longitude': item['longitude'],
                }
                restaurantsData.append(restaurant)
        return jsonify({'message': 'Data stored successfully', 'restaurants': restaurantsData}), 201

    elif request.method == 'GET':
        return jsonify({'stores': restaurantsData}), 200


@auth_bp.route('/products', methods=['GET'])
def get_all_products():
    # Get a unique list of all products from all restaurants
    all_products = set()
    for restaurant in restaurantsData:
        all_products.update(restaurant.get('products', []))

    return jsonify({'products': list(all_products)}), 200


@auth_bp.route('/search/product/<product_name>', methods=['GET'])
def search_by_product(product_name):
    # Find all restaurants that have the specified product
    matching_restaurants = [
        restaurant for restaurant in restaurantsData
        if product_name in restaurant.get('products', [])
    ]

    return jsonify({'restaurants': matching_restaurants}), 200
