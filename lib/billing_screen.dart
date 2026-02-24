import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  double total = 0;
  Map<String, int> cart = {};
  Map<String, Map<String, dynamic>> cartProducts = {};

  // 🔥 Add to Cart (NO stock reduce here)
  void addToCart(DocumentSnapshot product) {
    int stock = product['qty'];

    if (stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Out of Stock")),
      );
      return;
    }

    setState(() {
      cart[product.id] = (cart[product.id] ?? 0) + 1;

      cartProducts[product.id] = {
        "name": product['name'],
        "price": product['price']
      };

      total += product['price'];
    });
  }

  // 🔥 Confirm Bill
  Future<void> confirmBill() async {
    if (cart.isEmpty) return;

    try {
      await firestore.runTransaction((transaction) async {
        // 🔹 Check & Update Stock
        for (var entry in cart.entries) {
          String productId = entry.key;
          int qtyPurchased = entry.value;

          DocumentReference productRef =
              firestore.collection('products').doc(productId);

          DocumentSnapshot snapshot = await transaction.get(productRef);

          int currentQty = snapshot['qty'];

          // 🔥 Prevent Negative Stock
          if (currentQty < qtyPurchased) {
            throw Exception("Insufficient stock for ${snapshot['name']}");
          }

          transaction.update(productRef, {'qty': currentQty - qtyPurchased});
        }

        // 🔹 Save Sale inside SAME transaction
        DocumentReference salesRef = firestore.collection('sales').doc();

        transaction.set(salesRef, {
          'total': total,
          'items': cart.map((key, value) => MapEntry(
                key,
                {
                  "name": cartProducts[key]!['name'],
                  "price": cartProducts[key]!['price'],
                  "qty": value
                },
              )),
          'createdAt': Timestamp.now(),
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bill Confirmed Successfully")),
      );

      setState(() {
        cart.clear();
        cartProducts.clear();
        total = 0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void clearBill() {
    setState(() {
      cart.clear();
      cartProducts.clear();
      total = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Billing Counter"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // 🔥 Product List
          Expanded(
            child: StreamBuilder(
              stream: firestore.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 15),
                      child: ListTile(
                        title: Text(
                          product['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            "₹${product['price']} | Stock: ${product['qty']}"),
                        trailing: ElevatedButton(
                          onPressed: () => addToCart(product),
                          child: const Text("Add"),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 🔥 Cart Summary Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.blue,
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
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      "₹${total.toStringAsFixed(2)}",
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
                  onPressed: confirmBill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Confirm Bill"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: clearBill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Clear Bill"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
