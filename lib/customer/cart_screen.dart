import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class CartScreen extends StatefulWidget {
  final Map<String, int> cart;
  final Map<String, Map<String, dynamic>> cartProducts;
  final double total;

  const CartScreen({
    super.key,
    required this.cart,
    required this.cartProducts,
    required this.total,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isLoading = false;

  double calculateTotal() {
    double total = 0;
    widget.cart.forEach((key, qty) {
      total += widget.cartProducts[key]!['price'] * qty;
    });
    return total;
  }

  // 🔥 PLACE ORDER
  Future<void> placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (widget.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cart is empty")),
      );
      return;
    }

    setState(() => isLoading = true);

    final firestore = FirebaseFirestore.instance;

    try {
      // 🔹 Get User Name
      final userDoc = await firestore.collection('users').doc(user.uid).get();

      final userName = userDoc['name'];

      await firestore.runTransaction((transaction) async {
        // 🔹 Check & Reduce Stock
        for (var entry in widget.cart.entries) {
          String productId = entry.key;
          int qtyPurchased = entry.value;

          DocumentReference productRef =
              firestore.collection('products').doc(productId);

          DocumentSnapshot snapshot = await transaction.get(productRef);

          int currentQty = snapshot['qty'];

          if (currentQty < qtyPurchased) {
            throw Exception("Not enough stock for ${snapshot['name']}");
          }

          transaction.update(productRef, {'qty': currentQty - qtyPurchased});
        }

        // 🔹 Create Order
        DocumentReference orderRef = firestore.collection('orders').doc();

        transaction.set(orderRef, {
          'userId': user.uid,
          'userName': userName,
          'userEmail': user.email,
          'items': widget.cart.map((key, value) => MapEntry(
                key,
                {
                  "name": widget.cartProducts[key]!['name'],
                  "price": widget.cartProducts[key]!['price'],
                  "qty": value
                },
              )),
          'total': calculateTotal(),
          'status': "Placed",
          'createdAt': Timestamp.now(),

          // 🔥 ADD THIS
          'statusHistory': {
            'Placed': FieldValue.serverTimestamp(),
          },
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order Placed Successfully 🎉")),
      );

      setState(() {
        widget.cart.clear();
        widget.cartProducts.clear();
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void removeItem(String productId) {
    setState(() {
      widget.cart.remove(productId);
      widget.cartProducts.remove(productId);
    });
  }

  void decreaseQty(String productId) {
    setState(() {
      if (widget.cart[productId]! > 1) {
        widget.cart[productId] = widget.cart[productId]! - 1;
      } else {
        widget.cart.remove(productId);
        widget.cartProducts.remove(productId);
      }
    });
  }

  void increaseQty(String productId) {
    setState(() {
      widget.cart[productId] = widget.cart[productId]! + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("My Cart"),
            backgroundColor: Colors.green,
          ),
          body: widget.cart.isEmpty
              ? const Center(
                  child: Text(
                    "Your Cart is Empty 🛒",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Column(
                  children: [
                    // 🔹 Cart List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(15),
                        itemCount: widget.cart.length,
                        itemBuilder: (context, index) {
                          String productId = widget.cart.keys.elementAt(index);

                          int qty = widget.cart[productId]!;

                          var product = widget.cartProducts[productId]!;
                          // String base64Image = product['imageBase64'] ?? "";
                          List images = product['images'] ?? [];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 15),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  // product['image'] != null
                                  //     ? Image.network(
                                  //         product['image'],
                                  //         width: 60,
                                  //         height: 60,
                                  //         fit: BoxFit.cover,
                                  //       )

                                  // base64Image.isNotEmpty
                                  images.isNotEmpty
                                      ? Image.memory(
                                          // base64Decode(base64Image),
                                                  base64Decode(images[0]), // 👈 first image
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.image, size: 50),

                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['name'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "₹${product['price']} x $qty = ₹${product['price'] * qty}",
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: () =>
                                                  decreaseQty(productId),
                                              icon: const Icon(Icons.remove),
                                            ),
                                            Text(qty.toString()),
                                            IconButton(
                                              onPressed: () =>
                                                  increaseQty(productId),
                                              icon: const Icon(Icons.add),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => removeItem(productId),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // 🔹 Total Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Total Amount",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              Text(
                                "₹${calculateTotal().toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            onPressed: isLoading ? null : placeOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text(
                              "Confirm Order",
                              style: TextStyle(color: Colors.green),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
        ),

        // 🔥 FULL SCREEN LOADER
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
