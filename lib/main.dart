import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping Cart Example',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: ShoppingCartPage(),
    );
  }
}

class ShoppingCartPage extends StatefulWidget {
  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  final Map<String, int> _cart = {};
  String _searchQuery = '';
  String? _selectedCategory;
  final List<Map<String, dynamic>> _orderHistory = [];

  // Define products as a class field
  final List<Map<String, dynamic>> products = [
    // Fruits
    {'name': 'Apple', 'price': 2.99, 'image': '🍎', 'category': 'Fruits'},
    {'name': 'Banana', 'price': 1.99, 'image': '🍌', 'category': 'Fruits'},
    {'name': 'Orange', 'price': 2.49, 'image': '🍊', 'category': 'Fruits'},
    {'name': 'Strawberry', 'price': 4.99, 'image': '🍓', 'category': 'Fruits'},
    {'name': 'Grapes', 'price': 3.99, 'image': '🍇', 'category': 'Fruits'},
    {'name': 'Watermelon', 'price': 5.99, 'image': '🍉', 'category': 'Fruits'},
    
    // Vegetables
    {'name': 'Carrot', 'price': 1.49, 'image': '🥕', 'category': 'Vegetables'},
    {'name': 'Broccoli', 'price': 2.29, 'image': '🥦', 'category': 'Vegetables'},
    {'name': 'Tomato', 'price': 1.99, 'image': '🍅', 'category': 'Vegetables'},
    {'name': 'Cucumber', 'price': 1.79, 'image': '🥒', 'category': 'Vegetables'},
    {'name': 'Potato', 'price': 2.99, 'image': '🥔', 'category': 'Vegetables'},
    
    // Dairy
    {'name': 'Milk', 'price': 3.49, 'image': '🥛', 'category': 'Dairy'},
    {'name': 'Cheese', 'price': 4.99, 'image': '🧀', 'category': 'Dairy'},
    {'name': 'Yogurt', 'price': 2.99, 'image': '🥛', 'category': 'Dairy'},
    
    // Bakery
    {'name': 'Bread', 'price': 2.49, 'image': '🍞', 'category': 'Bakery'},
    {'name': 'Croissant', 'price': 1.99, 'image': '🥐', 'category': 'Bakery'},
    {'name': 'Bagel', 'price': 1.79, 'image': '🥯', 'category': 'Bakery'},
  ];

  void _addItem(String itemName) {
    setState(() {
      if (_cart.containsKey(itemName)) {
        _cart[itemName] = _cart[itemName]! + 1;
      } else {
        _cart[itemName] = 1;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $itemName to cart'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeItem(String itemName) {
    setState(() {
      if (_cart.containsKey(itemName)) {
        if (_cart[itemName]! > 1) {
          _cart[itemName] = _cart[itemName]! - 1;
        } else {
          _cart.remove(itemName);
        }
      }
    });
  }

  void _addToOrderHistory(Map<String, int> orderItems) {
    final order = {
      'date': DateTime.now(),
      'items': Map<String, int>.from(orderItems),
      'total': _calculateTotal(orderItems),
    };
    setState(() {
      _orderHistory.insert(0, order);
    });
  }

  double _calculateTotal(Map<String, int> items) {
    double total = 0;
    items.forEach((item, quantity) {
      final product = products.firstWhere(
        (p) => p['name'] == item,
        orElse: () => {'price': 0.0},
      );
      total += product['price'] * quantity;
    });
    return total;
  }

  void _reorderItems(Map<String, int> items) {
    setState(() {
      _cart.clear();
      items.forEach((item, quantity) {
        _cart[item] = quantity;
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Items added to cart'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _viewOrderHistory() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.history, color: Colors.teal),
            SizedBox(width: 8),
            Text('Order History'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: _orderHistory.isEmpty
              ? Center(
                  child: Text(
                    'No orders yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _orderHistory.length,
                  itemBuilder: (context, index) {
                    final order = _orderHistory[index];
                    final date = order['date'] as DateTime;
                    final items = order['items'] as Map<String, int>;
                    final total = order['total'] as double;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ExpansionTile(
                        title: Text(
                          'Order #${_orderHistory.length - index}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${date.day}/${date.month}/${date.year} - \$${total.toStringAsFixed(2)}',
                        ),
                        children: [
                          ...items.entries.map((entry) {
                            final product = products.firstWhere(
                              (p) => p['name'] == entry.key,
                              orElse: () => {'price': 0.0, 'image': '❓'},
                            );
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.teal[100],
                                child: Text(
                                  product['image'],
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              title: Text(entry.key),
                              subtitle: Text('\$${(product['price'] * entry.value).toStringAsFixed(2)}'),
                              trailing: Text('x${entry.value}'),
                            );
                          }).toList(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _reorderItems(items);
                              },
                              child: Text('Reorder Items'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewCart() {
    double total = 0;
    _cart.forEach((item, quantity) {
      final product = products.firstWhere(
        (p) => p['name'] == item,
        orElse: () => {'price': 0.0},
      );
      total += product['price'] * quantity;
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.shopping_cart, color: Colors.teal),
            SizedBox(width: 8),
            Text('Your Cart'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: _cart.isEmpty
              ? Center(
                  child: Text(
                    'Your cart is empty',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _cart.length,
                      itemBuilder: (context, index) {
                        String item = _cart.keys.elementAt(index);
                        int quantity = _cart[item]!;
                        final product = products.firstWhere(
                          (p) => p['name'] == item,
                          orElse: () => {'price': 0.0, 'image': '❓'},
                        );
                        
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal[100],
                              child: Text(
                                product['image'],
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            title: Text(item),
                            subtitle: Text('\$${(product['price'] * quantity).toStringAsFixed(2)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    setState(() {
                                      _removeItem(item);
                                    });
                                    Navigator.pop(context);
                                    _viewCart();
                                  },
                                ),
                                Text(
                                  'x$quantity',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline),
                                  onPressed: () {
                                    setState(() {
                                      _addItem(item);
                                    });
                                    Navigator.pop(context);
                                    _viewCart();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          if (_cart.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                _addToOrderHistory(_cart);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order placed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                setState(() {
                  _cart.clear();
                });
              },
              child: Text('Checkout'),
            ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredProducts {
    return products.where((product) {
      final matchesSearch = product['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == null || product['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<String> get _categories {
    return products.map((p) => p['category'] as String).toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fresh Market'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: _viewOrderHistory,
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: _viewCart,
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _cart.values.reduce((a, b) => a + b).toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(
                  label: Text('All'),
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.teal[100],
                  checkmarkColor: Colors.teal,
                ),
                SizedBox(width: 8),
                ..._categories.map((category) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.teal[100],
                    checkmarkColor: Colors.teal,
                  ),
                )).toList(),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.teal[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              product['image'],
                              style: TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '\$${product['price'].toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.teal,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _addItem(product['name']),
                          child: Text('Add to Cart'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}