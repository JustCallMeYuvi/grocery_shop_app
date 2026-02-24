// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:grocery_shop_app/add_product_screen.dart';
// import 'package:image_picker/image_picker.dart';

// class ProductScreen extends StatefulWidget {
//   const ProductScreen({super.key});

//   @override
//   State<ProductScreen> createState() => _ProductScreenState();
// }

// class _ProductScreenState extends State<ProductScreen> {
//   final firestore = FirebaseFirestore.instance;

//   final nameController = TextEditingController();
//   final priceController = TextEditingController();
//   final qtyController = TextEditingController();
//   final descController = TextEditingController();

//   File? selectedImage;
//   bool isLoading = false;

//   // 🔥 PICK IMAGE (Camera + Gallery)
//   Future<void> pickImage() async {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text("Take Photo"),
//                 onTap: () async {
//                   Navigator.pop(context);
//                   final picked = await ImagePicker().pickImage(
//                     source: ImageSource.camera,
//                     imageQuality: 60,
//                   );

//                   if (picked != null) {
//                     setState(() {
//                       selectedImage = File(picked.path);
//                     });
//                   }
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.photo),
//                 title: const Text("Choose from Gallery"),
//                 onTap: () async {
//                   Navigator.pop(context);
//                   final picked = await ImagePicker().pickImage(
//                     source: ImageSource.gallery,
//                     imageQuality: 60,
//                   );

//                   if (picked != null) {
//                     setState(() {
//                       selectedImage = File(picked.path);
//                     });
//                   }
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // 🔥 Convert Image to Base64
//   Future<String> convertToBase64(File image) async {
//     List<int> bytes = await image.readAsBytes();
//     return base64Encode(bytes);
//   }

//   // 🔥 ADD PRODUCT
//   Future<void> addProduct() async {
//     if (nameController.text.isEmpty ||
//         priceController.text.isEmpty ||
//         qtyController.text.isEmpty ||
//         descController.text.isEmpty ||
//         selectedImage == null) {
//       showDialog(
//         context: context,
//         builder: (context) => const AlertDialog(
//           title: Text("Missing Fields"),
//           content: Text("Please fill all fields and select product image."),
//         ),
//       );
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       String base64Image = await convertToBase64(selectedImage!);

//       await firestore.collection('products').add({
//         'name': nameController.text.trim(),
//         'price': double.parse(priceController.text),
//         'qty': int.parse(qtyController.text),
//         'description': descController.text.trim(),
//         'imageBase64': base64Image,
//         'createdAt': Timestamp.now(),
//       });

//       // Clear Fields
//       nameController.clear();
//       priceController.clear();
//       qtyController.clear();
//       descController.clear();
//       selectedImage = null;

//       setState(() => isLoading = false);

//       Navigator.pop(context); // close bottom sheet

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Product Added Successfully"),
//         ),
//       );
//     } catch (e) {
//       setState(() => isLoading = false);

//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("Error"),
//           content: Text(e.toString()),
//         ),
//       );
//     }
//   }

//   // 🔥 DELETE PRODUCT
//   Future<void> deleteProduct(String id) async {
//     await firestore.collection('products').doc(id).delete();
//   }

//   // 🔥 SHOW ADD PRODUCT SHEET
//   void showAddProductSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             return Padding(
//               padding: EdgeInsets.only(
//                   bottom: MediaQuery.of(context).viewInsets.bottom),
//               child: SingleChildScrollView(
//                 child: Container(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Text(
//                         "Add New Product",
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 15),
//                       TextField(
//                         controller: nameController,
//                         decoration: const InputDecoration(
//                           labelText: "Product Name",
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       TextField(
//                         controller: priceController,
//                         keyboardType: TextInputType.number,
//                         decoration: const InputDecoration(
//                           labelText: "Price",
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       TextField(
//                         controller: qtyController,
//                         keyboardType: TextInputType.number,
//                         decoration: const InputDecoration(
//                           labelText: "Stock Quantity",
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       TextField(
//                         controller: descController,
//                         maxLines: 3,
//                         decoration: const InputDecoration(
//                           labelText: "Product Description",
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       selectedImage != null
//                           ? Image.file(selectedImage!, height: 100)
//                           : const Text("No Image Selected"),
//                       const SizedBox(height: 10),
//                       ElevatedButton(
//                         onPressed: pickImage,
//                         child: const Text("Select Product Image"),
//                       ),
//                       const SizedBox(height: 20),
//                       isLoading
//                           ? const CircularProgressIndicator()
//                           : ElevatedButton(
//                               onPressed: addProduct,
//                               style: ElevatedButton.styleFrom(
//                                   minimumSize: const Size(double.infinity, 50)),
//                               child: const Text("Add Product"),
//                             ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Products"),
//         centerTitle: true,
//         backgroundColor: Colors.green,
//       ),
//       floatingActionButton: FloatingActionButton(
//         // onPressed: showAddProductSheet,

//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const AddProductScreen()),
//           );
//         },
//         backgroundColor: Colors.green,
//         child: const Icon(Icons.add),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: firestore.collection('products').snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final products = snapshot.data!.docs;

//           if (products.isEmpty) {
//             return const Center(child: Text("No Products Added Yet"));
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(15),
//             itemCount: products.length,
//             itemBuilder: (context, index) {
//               final doc = products[index];
//               final data = doc.data() as Map<String, dynamic>;

//               // String base64Image = data['imageBase64'] ?? '';
//               List images = data['images'] ?? [];

//               Widget productImage;

//               if (images.isNotEmpty) {
//                 productImage = ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: Image.memory(
//                     base64Decode(images[0]), // 👈 Show first image
//                     height: 80,
//                     width: 80,
//                     fit: BoxFit.cover,
//                   ),
//                 );
//               } else {
//                 productImage = Container(
//                   height: 80,
//                   width: 80,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(Icons.image, color: Colors.grey),
//                 );
//               }
//               String name = data['name'] ?? '';
//               String description = data['description'] ?? '';
//               var price = data['price'] ?? 0;
//               var qty = data['qty'] ?? 0;

//               return Card(
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15)),
//                 margin: const EdgeInsets.only(bottom: 15),
//                 child: Padding(
//                   padding: const EdgeInsets.all(10),
//                   child: Row(
//                     children: [
//                       // base64Image.isNotEmpty
//                       //     ? Image.memory(
//                       //         base64Decode(base64Image),
//                       //         height: 80,
//                       //         width: 80,
//                       //         fit: BoxFit.cover,
//                       //       )
//                       //     : Container(
//                       //         height: 80,
//                       //         width: 80,
//                       //         color: Colors.grey.shade300,
//                       //         child:
//                       //             const Icon(Icons.image, color: Colors.grey),
//                       //       ),
//                       productImage,
//                       const SizedBox(width: 15),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(name,
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold)),
//                             const SizedBox(height: 5),
//                             Text(description,
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: const TextStyle(
//                                     fontSize: 12, color: Colors.grey)),
//                             const SizedBox(height: 5),
//                             Text("₹$price | Stock: $qty",
//                                 style: const TextStyle(color: Colors.green)),
//                           ],
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.delete, color: Colors.red),
//                         onPressed: () => deleteProduct(doc.id),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_shop_app/add_product_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final firestore = FirebaseFirestore.instance;

  Future<void> deleteProduct(String id) async {
    await firestore.collection('products').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),

      // ================= RESPONSIVE BODY =================

      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('products').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final products = snapshot.data!.docs;

                  if (products.isEmpty) {
                    return const Center(child: Text("No Products Added Yet"));
                  }

                  // 📱 MOBILE
                  if (width < 800) {
                    return _buildMobileList(products);
                  }

                  // 💻 TABLET / WEB
                  return _buildWebGrid(products, width);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= MOBILE LIST =================

  Widget _buildMobileList(List products) {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index], isWeb: false);
      },
    );
  }

  // ================= WEB GRID =================

  Widget _buildWebGrid(List products, double width) {
    int crossAxisCount = 2;

    if (width > 1100) {
      crossAxisCount = 3;
    }

    return GridView.builder(
      padding: const EdgeInsets.all(30),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 25,
        mainAxisSpacing: 25,
        // mainAxisExtent: 280,
        mainAxisExtent: width > 1100 ? 320 : 300,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return _buildProductCard(products[index], isWeb: true);
      },
    );
  }

  // ================= PRODUCT CARD =================

  Widget _buildProductCard(DocumentSnapshot doc, {required bool isWeb}) {
    final data = doc.data() as Map<String, dynamic>;

    List images = data['images'] ?? [];

    Widget productImage;

    if (images.isNotEmpty) {
      productImage = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.memory(
          base64Decode(images[0]),
          height: isWeb ? 120 : 80,
          width: isWeb ? double.infinity : 80,
          fit: BoxFit.cover,
        ),
      );
    } else {
      productImage = Container(
        height: isWeb ? 120 : 80,
        width: isWeb ? double.infinity : 80,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }

    String name = data['name'] ?? '';
    String description = data['description'] ?? '';
    var price = data['price'] ?? 0;
    var qty = data['qty'] ?? 0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: isWeb
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  productImage,
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  // const Spacer(),
                  const SizedBox(height: 10),
                  Text(
                    "₹$price | Stock: $qty",
                    style: const TextStyle(color: Colors.green),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        bool? confirm = await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete Product"),
                            content: const Text(
                                "Are you sure you want to delete this product?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await deleteProduct(doc.id);
                        }
                      },
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  productImage,
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "₹$price | Stock: $qty",
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    // onPressed: () => deleteProduct(doc.id),
                    onPressed: () async {
                      bool? confirm = await showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Delete Product"),
                          content: const Text(
                              "Are you sure you want to delete this product?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await deleteProduct(doc.id);
                      }
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
