import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EcommerceScreen(),
    );
  }
}

class EcommerceScreen extends StatefulWidget {
  @override
  _EcommerceScreenState createState() => _EcommerceScreenState();
}

class _EcommerceScreenState extends State<EcommerceScreen> {
  // This will store the cart items
  List<Map<String, dynamic>> cartItems = [];
  int _selectedIndex = 0; // For bottom navigation bar

  // Method to add product to the cart
  void addToCart(String productName, int price) {
    setState(() {
      // Check if the product is already in the cart
      int index = cartItems.indexWhere((item) => item['name'] == productName);
      if (index != -1) {
        cartItems[index]['quantity'] = cartItems[index]['quantity'] + 1;
      } else {
        cartItems.add({'name': productName, 'price': price, 'quantity': 1});
      }
    });
  }

  // Method to remove a product from the cart
  void removeFromCart(String productName) {
    setState(() {
      cartItems.removeWhere((item) => item['name'] == productName);
    });
  }

  // Method to change the selected screen
  void _onItemTapped(int index) {
    if (index == 1) {
      // Open the cart as a modal bottom sheet
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return FractionallySizedBox(
                heightFactor: 0.5, // Set height to 50% of the screen
                child: CartScreen(
                  cartItems: cartItems,
                  removeFromCart: (productName) {
                    setState(() {
                      removeFromCart(productName);
                    });
                    // Update modal state as well
                    setModalState(() {});
                  },
                ),
              );
            },
          );
        },
        isScrollControlled: true, // Allows full control over the height
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'E-Commerce Site',
          style: TextStyle(
            color: Colors.white,  // Set the title text color to white
            fontSize: 25.0,       // Optional: set font size if needed
          ),
        ),
        backgroundColor: Color(0xFF4C4C4C),
      ),
      body: ProductGrid(addToCart: addToCart),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}

class ProductGrid extends StatelessWidget {
  final Function addToCart;

  ProductGrid({required this.addToCart});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemCount: 6, // Change this if you have more products
      itemBuilder: (context, index) {
        return ProductCard(
          productName: 'Shirt ${index + 1}',
          price: 500 + (index * 50),
          addToCart: addToCart,
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final String productName;
  final int price;
  final Function addToCart;

  ProductCard({required this.productName, required this.price, required this.addToCart});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Use the asset image instead of the network placeholder
          Image.asset('assets/images/shirt.png', height: 100),
          SizedBox(height: 10),
          Text(
            productName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 16),
              Text('4.5', style: TextStyle(color: Colors.black)),
            ],
          ),
          Text('₹$price', style: TextStyle(fontSize: 18)),
          SizedBox(height: 5),
          ElevatedButton(
            onPressed: () {
              addToCart(productName, price);
            },
            child: Text('Add to Cart'),
          ),
        ],
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function removeFromCart;

  CartScreen({required this.cartItems, required this.removeFromCart});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: cartItems.isEmpty
              ? Center(child: Text('No items in your cart'))
              : ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              return CartItem(
                productName: cartItems[index]['name'],
                price: cartItems[index]['price'],
                quantity: cartItems[index]['quantity'],
                removeFromCart: removeFromCart,
              );
            },
          ),
        ),
        if (cartItems.isNotEmpty) PriceDetails(cartItems: cartItems),
      ],
    );
  }
}

class CartItem extends StatelessWidget {
  final String productName;
  final int price;
  final int quantity;
  final Function removeFromCart;

  CartItem(
      {required this.productName, required this.price, required this.quantity, required this.removeFromCart});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.asset('assets/images/shirt.png', height: 100),
        title: Text(productName),
        subtitle: Text('₹$price x $quantity'),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            removeFromCart(productName);
          },
        ),
      ),
    );
  }
}

class PriceDetails extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;

  PriceDetails({required this.cartItems});

  int calculateTotal() {
    int total = 0;
    for (var item in cartItems) {
      total += item['price'] * item['quantity'] as int;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    int totalAmount = calculateTotal();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('₹$totalAmount', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              // Proceed with placing the order

            },
            child: Text('Place Order'),
          ),
        ],
      ),
    );
  }
}
