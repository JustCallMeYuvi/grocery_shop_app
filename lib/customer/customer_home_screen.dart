import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_shop_app/customer/cart_screen.dart';
import 'package:grocery_shop_app/customer/customer_profile_screen.dart';
import 'package:grocery_shop_app/customer/my_orders_screen.dart';
import 'package:grocery_shop_app/customer/product_detail_screen.dart';
import 'package:grocery_shop_app/main.dart';
import '../auth_screen.dart';
import 'dart:convert'; // Make sure this is added at top
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  Map<String, int> cart = {};
  Map<String, Map<String, dynamic>> cartProducts = {};

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _listenForOrderUpdates();
  }

  void _listenForOrderUpdates() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'];
        print("Listener triggered");
        print("Status: $status");

        if (status == "Delivered" && data['notified'] != true) {
          Map<String, dynamic> items = Map<String, dynamic>.from(data['items']);
          // Get first product (since single product order)
          var firstItem = items.values.first;
          String productName = firstItem['name'] ?? "Product";
          // Get user name from email
          String email = data['userEmail'] ?? "";
          String userName = email.isNotEmpty ? email.split('@')[0] : "Customer";

          _showLocalNotification(
            "Order Delivered 🎉",
            "Hi $userName,Your $productName has been delivered successfully.",
          );

          doc.reference.update({'notified': true});
        }
      }
    });
  }

  void _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'order_channel',
      'Order Notifications',
      channelDescription: 'Order status updates',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = 2;

    if (screenWidth > 1200) {
      crossAxisCount = 5; // Large Web
    } else if (screenWidth > 800) {
      crossAxisCount = 4; // Tablet / Small Web
    } else if (screenWidth > 600) {
      crossAxisCount = 3; // Large Mobile
    } else {
      crossAxisCount = 2; // Normal Mobile
    }
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    void addToCart(DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;

      int stock = data['qty'] ?? 0;

      if (stock <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Out of Stock")),
        );
        return;
      }

      setState(() {
        cart[doc.id] = (cart[doc.id] ?? 0) + 1;

        cartProducts[doc.id] = {
          "name": data['name'],
          "price": data['price'],
          // "image": data['image'],
          // "imageBase64": data['imageBase64'], // 🔥 IMPORTANT
          "images": data['images'], // 🔥 updated multiple images
        };
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to Cart")),
      );
    }

    double getTotal() {
      double total = 0;
      cart.forEach((key, value) {
        total += cartProducts[key]!['price'] * value;
      });
      return total;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        title: Text(
          "Hi, ${user?.email?.split('@')[0] ?? "User"} 👋",
        ),
        actions: [
          // 🛒 CART ICON WITH BADGE
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CartScreen(
                        cart: cart,
                        cartProducts: cartProducts,
                        total: getTotal(),
                      ),
                    ),
                  );

                  // 🔥 Refresh UI after returning
                  setState(() {});
                },
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cart.length.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CustomerProfileScreen(),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.shopping_bag),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyOrdersScreen(),
                ),
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const AuthScreen()),
                          (route) => false,
                        );
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: firestore.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // final products = snapshot.data!.docs;

          final allProducts = snapshot.data!.docs;

          final products = allProducts.where((doc) {
            final data = doc.data();
            final name = (data['name'] ?? "").toString().toLowerCase();

            return name.contains(_searchQuery);
          }).toList();
          // 👇 WRITE HERE
          print("Products count: ${products.length}");
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: CustomScrollView(
                slivers: [
                  /// 🔍 Search
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Search groceries...",
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = "";
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// 🟢 Offer Banner
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      // height: 150,
                      height: screenWidth > 800 ? 220 : 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        image: const DecorationImage(
                          image: NetworkImage(
                              "https://images.unsplash.com/photo-1606787366850-de6330128bfc"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  /// 🏷 Categories Title
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Categories",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  /// 🏷 Categories List
                  SliverToBoxAdapter(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double width = constraints.maxWidth;

                        // 📱 Mobile
                        if (width < 700) {
                          return SizedBox(
                            height: 100,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              children: _buildCategories(isWeb: false),
                            ),
                          );
                        }

                        // 💻 Web / Tablet
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Wrap(
                            spacing: 40,
                            runSpacing: 20,
                            alignment: WrapAlignment.start,
                            children: _buildCategories(isWeb: true),
                          ),
                        );
                      },
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  /// 🛒 Popular Products Title
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Popular Products",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 15)),

                  /// 🛒 Products Grid
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final doc = products[index];
                          // final data = doc.data();

                          // final String imageUrl = data['image'] ??
                          //     "https://images.unsplash.com/photo-1580910051074-3eb694886505";
                          final data = doc.data() as Map<String, dynamic>;

                          // final String base64Image = data['imageBase64'] ?? "";
                          List images = data['images'] ?? [];
                          final String name = data['name'] ?? "No Name";
                          final price = data['price'] ?? 0;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(
                                    product: doc,
                                    onAddToCart: addToCart,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    blurRadius: 10,
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  /// 🖼 Image (SAFE)
                                  AspectRatio(
                                    aspectRatio: 1.3,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(25),
                                      ),
                                      child:
                                          // base64Image.isNotEmpty
                                          //     ? Image.memory(
                                          //         base64Decode(base64Image),
                                          //         fit: BoxFit.cover,
                                          //         width: double.infinity,
                                          //       )
                                          images.isNotEmpty
                                              ? Image.memory(
                                                  base64Decode(images[
                                                      0]), // 👈 show first image
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                )
                                              : Image.network(
                                                  "https://images.unsplash.com/photo-1580910051074-3eb694886505",
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                ),
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "₹$price",
                                          style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            minimumSize:
                                                const Size(double.infinity, 40),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                          onPressed: () => addToCart(doc),
                                          child: const Text("Add to Cart"),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: products.length,
                      ),
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         // crossAxisCount: 2,
//                         // crossAxisSpacing: 15,
//                         // mainAxisSpacing: 15,
//                         // childAspectRatio: 0.72,
//                         crossAxisCount: crossAxisCount,
//                         crossAxisSpacing: 20,
//                         mainAxisSpacing: 20,
// childAspectRatio: screenWidth > 800 ? 0.95 : 0.75,
//                       ),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: screenWidth > 1200
                            ? 250
                            : screenWidth > 800
                                ? 220
                                : 200,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        mainAxisExtent: 340, // 🔥 FIXED HEIGHT FOR CARD
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _categoryItem(String title, String imageUrl, bool isWeb) {
    return SizedBox(
      width: isWeb ? 120 : 80,
      child: Column(
        children: [
          CircleAvatar(
            radius: isWeb ? 40 : 30,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: isWeb ? 14 : 12),
          )
        ],
      ),
    );
  }

  List<Widget> _buildCategories({required bool isWeb}) {
    return [
      _categoryItem(
          "Fruits",
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT1A-FsvqrAcOIskq-YGXlUjQcoR0ln3w6omw&s",
          isWeb),
      _categoryItem(
          "Vegetables",
          "https://images.unsplash.com/photo-1540420773420-3366772f4999",
          isWeb),
      _categoryItem(
          "Dairy",
          "https://images.unsplash.com/photo-1580910051074-3eb694886505",
          isWeb),
      _categoryItem(
          "Snacks",
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT9NlH1nCs1MkxFZdTnmSqf0JDPi-rJYwZKwg&s",
          isWeb),
    ];
  }
}
