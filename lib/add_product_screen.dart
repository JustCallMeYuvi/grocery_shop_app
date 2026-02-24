import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final firestore = FirebaseFirestore.instance;

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final qtyController = TextEditingController();
  final descController = TextEditingController();

  // List<File> selectedImages = [];
  List<XFile> selectedImages = [];
  bool isLoading = false;

  final ImagePicker picker = ImagePicker();

  // 🔥 Pick From Gallery (Multiple)
  // Future<void> pickMultipleImages() async {
  //   final pickedFiles = await picker.pickMultiImage(imageQuality: 60);

  //   if (pickedFiles.isNotEmpty) {
  //     setState(() {
  //       selectedImages.addAll(
  //         pickedFiles.map((e) => File(e.path)),
  //       );
  //     });
  //   }
  // }

  // 🔥 Pick From Gallery (Multiple)

  Future<void> pickMultipleImages() async {
    final pickedFiles = await picker.pickMultiImage(imageQuality: 60);

    if (pickedFiles.isNotEmpty) {
      setState(() {
        selectedImages.addAll(pickedFiles);
      });
    }
  }

// 🔥 Capture From Camera
  Future<void> captureImage() async {
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 60,
    );

    if (picked != null) {
      setState(() {
        selectedImages.add(picked);
      });
    }
  }
  // 🔥 Capture From Camera
  // Future<void> captureImage() async {
  //   final picked = await picker.pickImage(
  //     source: ImageSource.camera,
  //     imageQuality: 60,
  //   );

  //   if (picked != null) {
  //     setState(() {
  //       selectedImages.add(File(picked.path));
  //     });
  //   }
  // }

  // 🔥 Convert All Images to Base64
  Future<List<String>> convertImagesToBase64() async {
    List<String> base64Images = [];

    for (XFile image in selectedImages) {
      List<int> bytes = await image.readAsBytes();
      base64Images.add(base64Encode(bytes));
    }

    return base64Images;
  }

  // 🔥 Add Product
  Future<void> addProduct() async {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        qtyController.text.isEmpty ||
        descController.text.isEmpty ||
        selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields & select images")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      List<String> imagesBase64 = await convertImagesToBase64();

      await firestore.collection('products').add({
        'name': nameController.text.trim(),
        'price': double.parse(priceController.text),
        'qty': int.parse(qtyController.text),
        'description': descController.text.trim(),
        'images': imagesBase64, // 🔥 MULTIPLE IMAGES
        'createdAt': Timestamp.now(),
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // breakpoints
    final isWeb = width > 900;
    final isTablet = width > 600 && width <= 900;

    int gridCount = 3;

    if (isWeb) {
      gridCount = 5;
    } else if (isTablet) {
      gridCount = 4;
    } else {
      gridCount = 3;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Product"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔥 Row layout for web
                isWeb
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildFormFields()),
                          const SizedBox(width: 40),
                          Expanded(child: _buildImageSection(gridCount)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildFormFields(),
                          const SizedBox(height: 20),
                          _buildImageSection(gridCount),
                        ],
                      ),
                // TextField(
                //   controller: nameController,
                //   decoration: const InputDecoration(
                //     labelText: "Product Name",
                //     border: OutlineInputBorder(),
                //   ),
                // ),
                // const SizedBox(height: 10),

                // TextField(
                //   controller: priceController,
                //   keyboardType: TextInputType.number,
                //   decoration: const InputDecoration(
                //     labelText: "Price",
                //     border: OutlineInputBorder(),
                //   ),
                // ),
                // const SizedBox(height: 10),

                // TextField(
                //   controller: qtyController,
                //   keyboardType: TextInputType.number,
                //   decoration: const InputDecoration(
                //     labelText: "Stock Quantity",
                //     border: OutlineInputBorder(),
                //   ),
                // ),
                // const SizedBox(height: 10),

                // // 🔥 Image Preview Grid
                // selectedImages.isNotEmpty
                //     ? GridView.builder(
                //         shrinkWrap: true,
                //         physics: const NeverScrollableScrollPhysics(),
                //         itemCount: selectedImages.length,
                //         gridDelegate:
                //             const SliverGridDelegateWithFixedCrossAxisCount(
                //           crossAxisCount: 3,
                //           crossAxisSpacing: 8,
                //           mainAxisSpacing: 8,
                //         ),
                //         itemBuilder: (context, index) {
                //           return Stack(
                //             children: [
                //               ClipRRect(
                //                 borderRadius: BorderRadius.circular(10),
                //                 child: Image.file(
                //                   selectedImages[index],
                //                   fit: BoxFit.cover,
                //                   width: double.infinity,
                //                 ),
                //               ),
                //               Positioned(
                //                 right: 0,
                //                 child: GestureDetector(
                //                   onTap: () {
                //                     setState(() {
                //                       selectedImages.removeAt(index);
                //                     });
                //                   },
                //                   child: Container(
                //                     color: Colors.black54,
                //                     child: const Icon(Icons.close,
                //                         color: Colors.white, size: 20),
                //                   ),
                //                 ),
                //               )
                //             ],
                //           );
                //         },
                //       )
                //     : const Text("No Images Selected"),

                // const SizedBox(height: 15),

                // Row(
                //   children: [
                //     Expanded(
                //       child: ElevatedButton.icon(
                //         onPressed: pickMultipleImages,
                //         icon: const Icon(Icons.photo),
                //         label: const Text("Gallery"),
                //       ),
                //     ),
                //     const SizedBox(width: 10),
                //     Expanded(
                //       child: ElevatedButton.icon(
                //         onPressed: captureImage,
                //         icon: const Icon(Icons.camera_alt),
                //         label: const Text("Camera"),
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 10),

                // TextField(
                //   controller: descController,
                //   maxLines: 3,
                //   decoration: const InputDecoration(
                //     labelText: "Description",
                //     border: OutlineInputBorder(),
                //   ),
                // ),

                const SizedBox(height: 20),

                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: addProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text("Add Product"),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: "Product Name",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Price",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Stock Quantity",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: descController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: "Description",
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(int gridCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Product Images",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        selectedImages.isNotEmpty
            ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedImages.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridCount,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:

                            // Image.file(
                            //   selectedImages[index],
                            //   fit: BoxFit.cover,
                            //   width: double.infinity,
                            // ),
                            FutureBuilder<Uint8List>(
                          future: selectedImages[index].readAsBytes(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedImages.removeAt(index);
                            });
                          },
                          child: Container(
                            color: Colors.black54,
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              )
            : const Text("No Images Selected"),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: pickMultipleImages,
                icon: const Icon(Icons.photo),
                label: const Text("Gallery"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: captureImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Camera"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
