// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:convert';
// import 'package:firebase_auth/firebase_auth.dart';

// class ProductDetailScreen extends StatefulWidget {
//   final DocumentSnapshot product;
//   final Function(DocumentSnapshot) onAddToCart;

//   const ProductDetailScreen({
//     super.key,
//     required this.product,
//     required this.onAddToCart,
//   });

//   @override
//   State<ProductDetailScreen> createState() => _ProductDetailScreenState();
// }

// class _ProductDetailScreenState extends State<ProductDetailScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final data = widget.product.data() as Map<String, dynamic>;

//     // final String imageUrl = data['image'] ??
//     //     "https://images.unsplash.com/photo-1580910051074-3eb694886505";
//     // final String base64Image = data['imageBase64'] ?? "";
//     List images = data['images'] ?? [];

//     final String name = data['name'] ?? "No Name";
//     final price = data['price'] ?? 0;
//     final description = data['description'] ?? "No description available";
//     final stock = data['qty'] ?? 0;

//     void showSuccessDialog() {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (dialogContext) {
//       return AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         content: const Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.check_circle, color: Colors.green, size: 80),
//             SizedBox(height: 15),
//             Text(
//               "Order Placed Successfully 🎉",
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 18),
//             ),
//           ],
//         ),
//       );
//     },
//   );

//   Future.delayed(const Duration(seconds: 2), () {
//     if (!mounted) return; // ✅ VERY IMPORTANT

//     Navigator.of(context, rootNavigator: true).pop(); // close dialog

//     if (mounted) {
//       Navigator.pop(context); // go back safely
//     }
//   });
// }

//     Future<void> placeSingleOrder() async {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) return;

//       final firestore = FirebaseFirestore.instance;

//       final data = widget.product.data() as Map<String, dynamic>;

//       final price = data['price'] ?? 0;
//       final name = data['name'] ?? "No Name";
//       final stock = data['qty'] ?? 0;

//       if (stock <= 0) return;

//       try {
//         // 🔹 Reduce stock
//         await firestore.runTransaction((transaction) async {
//           DocumentReference productRef =
//               firestore.collection('products').doc(widget.product.id);

//           DocumentSnapshot snapshot = await transaction.get(productRef);

//           int currentQty = snapshot['qty'];

//           if (currentQty <= 0) {
//             throw Exception("Out of stock");
//           }

//           transaction.update(productRef, {'qty': currentQty - 1});

//           // 🔹 Create Order
//           DocumentReference orderRef = firestore.collection('orders').doc();

//           transaction.set(orderRef, {
//             'userId': user.uid,
//             'userEmail': user.email,
//             'items': {
//               widget.product.id: {"name": name, "price": price, "qty": 1}
//             },
//             'total': price,
//             'status': "Placed",
//             'createdAt': Timestamp.now(),

//             // 🔥 ADD THIS for time details for order
//             'statusHistory': {
//               'Placed': FieldValue.serverTimestamp(),
//             },
//           });
//         });

//         showSuccessDialog();
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error: $e")),
//         );
//       }
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(name),
//         backgroundColor: Colors.green,
//       ),

//       /// 🔥 Scrollable Content
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// 🖼 Product Image
//             // base64Image.isNotEmpty
//             //     ? Image.memory(
//             //         base64Decode(base64Image),
//             //         height: 300,
//             //         width: double.infinity,
//             //         fit: BoxFit.cover,
//             //       )
//             //     : Image.network(
//             //         "https://images.unsplash.com/photo-1580910051074-3eb694886505",
//             //         height: 300,
//             //         width: double.infinity,
//             //         fit: BoxFit.cover,
//             //       ),

//             images.isNotEmpty
//                 ? SizedBox(
//                     height: 300,
//                     child: PageView.builder(
//                       itemCount: images.length,
//                       itemBuilder: (context, index) {
//                         return Image.memory(
//                           base64Decode(images[index]),
//                           fit: BoxFit.cover,
//                           width: double.infinity,
//                         );
//                       },
//                     ),
//                   )
//                 : Image.network(
//                     "https://images.unsplash.com/photo-1580910051074-3eb694886505",
//                     height: 300,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                   ),

//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     name,
//                     style: const TextStyle(
//                         fontSize: 24, fontWeight: FontWeight.bold),
//                   ),

//                   const SizedBox(height: 10),

//                   Text(
//                     "₹$price",
//                     style: const TextStyle(
//                         fontSize: 22,
//                         color: Colors.green,
//                         fontWeight: FontWeight.bold),
//                   ),

//                   const SizedBox(height: 10),

//                   Text(
//                     "Stock: $stock",
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: stock > 0 ? Colors.green : Colors.red,
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   const Text(
//                     "Product Description",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),

//                   const SizedBox(height: 10),

//                   Text(
//                     description,
//                     style: const TextStyle(fontSize: 16),
//                   ),

//                   const SizedBox(height: 100),
//                   // Space for bottom button
//                 ],
//               ),
//             ),

//             const SizedBox(height: 70),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                   ),
//                   onPressed: stock > 0
//                       ? () {
//                           showDialog(
//                             context: context,
//                             builder: (context) => AlertDialog(
//                               title: const Text("Confirm Order"),
//                               content: const Text(
//                                   "Are you sure you want to place this order?"),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Navigator.pop(context),
//                                   child: const Text("Cancel"),
//                                 ),
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     Navigator.pop(context);
//                                     placeSingleOrder();
//                                   },
//                                   child: const Text("Confirm"),
//                                 )
//                               ],
//                             ),
//                           );
//                         }
//                       : null,
//                   child: Text(
//                     stock > 0 ? "Order Now" : "Out of Stock",
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailScreen extends StatefulWidget {
  final DocumentSnapshot product;
  final Function(DocumentSnapshot) onAddToCart;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final data = widget.product.data() as Map<String, dynamic>;

    List images = data['images'] ?? [];
    final String name = data['name'] ?? "No Name";
    final price = data['price'] ?? 0;
    final description = data['description'] ?? "No description available";
    final stock = data['qty'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return _buildWebLayout(
                      images, name, price, stock, description);
                } else {
                  return _buildMobileLayout(
                      images, name, price, stock, description);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  // ================= MOBILE LAYOUT =================

  Widget _buildMobileLayout(
    List images,
    String name,
    dynamic price,
    dynamic stock,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageSection(images, 300),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildDetails(name, price, stock, description),
        ),
      ],
    );
  }

  // ================= WEB LAYOUT =================

  Widget _buildWebLayout(
    List images,
    String name,
    dynamic price,
    dynamic stock,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildImageSection(images, 450),
          ),
          const SizedBox(width: 50),
          Expanded(
            child: _buildDetails(name, price, stock, description),
          ),
        ],
      ),
    );
  }

  // ================= IMAGE SECTION =================

  Widget _buildImageSection(List images, double height) {
    if (images.isNotEmpty) {
      return SizedBox(
        height: height,
        child: PageView.builder(
          itemCount: images.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.memory(
                base64Decode(images[index]),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            );
          },
        ),
      );
    }

    return Image.network(
      "https://images.unsplash.com/photo-1580910051074-3eb694886505",
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  // ================= DETAILS SECTION =================

  Widget _buildDetails(
    String name,
    dynamic price,
    dynamic stock,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Text(
          "₹$price",
          style: const TextStyle(
              fontSize: 26, color: Colors.green, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          "Stock: $stock",
          style: TextStyle(
            fontSize: 18,
            color: stock > 0 ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          "Product Description",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 40),
        _buildOrderButton(stock),
      ],
    );
  }

  // ================= ORDER BUTTON =================

  Widget _buildOrderButton(dynamic stock) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        // onPressed: stock > 0 ? _confirmOrder : null,
        onPressed: (stock > 0 && !_isLoading) ? _confirmOrder : null,
        child: _isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                stock > 0 ? "Order Now" : "Out of Stock",
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  // ================= CONFIRM ORDER =================

  void _confirmOrder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Order"),
        content: const Text("Are you sure you want to place this order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _placeSingleOrder();
            },
            child: const Text("Confirm"),
          )
        ],
      ),
    );
  }

  // ================= PLACE ORDER =================

  Future<void> _placeSingleOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _isLoading = true);

    final firestore = FirebaseFirestore.instance;
    final data = widget.product.data() as Map<String, dynamic>;

    final price = data['price'] ?? 0;
    final name = data['name'] ?? "No Name";

    try {
      await firestore.runTransaction((transaction) async {
        DocumentReference productRef =
            firestore.collection('products').doc(widget.product.id);

        DocumentSnapshot snapshot = await transaction.get(productRef);

        int currentQty = snapshot['qty'];

        if (currentQty <= 0) {
          throw Exception("Out of stock");
        }

        transaction.update(productRef, {'qty': currentQty - 1});

        DocumentReference orderRef = firestore.collection('orders').doc();

        transaction.set(orderRef, {
          'userId': user.uid,
          'userEmail': user.email,
          'items': {
            widget.product.id: {"name": name, "price": price, "qty": 1}
          },
          'total': price,
          'status': "Placed",
          'createdAt': Timestamp.now(),
          'statusHistory': {
            'Placed': FieldValue.serverTimestamp(),
          },
        });
      }); 

      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ================= SUCCESS DIALOG =================

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 80),
              SizedBox(height: 15),
              Text(
                "Order Placed Successfully 🎉",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }
}
