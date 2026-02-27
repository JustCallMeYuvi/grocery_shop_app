import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  bool _isLoading = false;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final houseController = TextEditingController();
  final streetController = TextEditingController();
  final areaController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  void _showLoader() {
    setState(() {
      _isLoading = true;
    });
  }

  void _hideLoader() {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> addAddress() async {
    try {
      _showLoader();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('addresses')
          .add({
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "houseNo": houseController.text.trim(),
        "street": streetController.text.trim(),
        "area": areaController.text.trim(),
        "city": cityController.text.trim(),
        "state": stateController.text.trim(),
        "pincode": pincodeController.text.trim(),
        "isDefault": false,
        "createdAt": FieldValue.serverTimestamp(),
      });

      clearControllers();
      Navigator.pop(context);
    } finally {
      _hideLoader();
    }
  }

  Future<void> updateAddress(String id) async {
    try {
      _showLoader();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('addresses')
          .doc(id)
          .update({
        "name": nameController.text.trim(),
        "phone": phoneController.text.trim(),
        "houseNo": houseController.text.trim(),
        "street": streetController.text.trim(),
        "area": areaController.text.trim(),
        "city": cityController.text.trim(),
        "state": stateController.text.trim(),
        "pincode": pincodeController.text.trim(),
      });

      clearControllers();
      Navigator.pop(context);
    } finally {
      _hideLoader();
    }
  }

  Future<void> deleteAddress(String id, bool isDefault) async {
    if (isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot delete default address"),
        ),
      );
      return;
    }
    try {
      _showLoader();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('addresses')
          .doc(id)
          .delete();
    } finally {
      _hideLoader();
    }
  }

  Future<void> setDefaultAddress(String id) async {
    try {
      _showLoader();

      var collection = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('addresses');

      var snapshot = await collection.get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({"isDefault": false});
      }

      await collection.doc(id).update({"isDefault": true});
    } finally {
      _hideLoader();
    }
  }

  void clearControllers() {
    nameController.clear();
    phoneController.clear();
    houseController.clear();
    streetController.clear();
    areaController.clear();
    cityController.clear();
    stateController.clear();
    pincodeController.clear();
  }

  void showAddAddressDialog({DocumentSnapshot? addressDoc}) {
    if (addressDoc != null) {
      // 🔥 Prefill values
      nameController.text = addressDoc['name'];
      phoneController.text = addressDoc['phone'];
      houseController.text = addressDoc['houseNo'];
      streetController.text = addressDoc['street'];
      areaController.text = addressDoc['area'];
      cityController.text = addressDoc['city'];
      stateController.text = addressDoc['state'];
      pincodeController.text = addressDoc['pincode'];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  addressDoc == null ? "Add Address" : "Edit Address",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                buildTextField(nameController, "Full Name"),
                buildTextField(phoneController, "Phone"),
                buildTextField(houseController, "House No"),
                buildTextField(streetController, "Street"),
                buildTextField(areaController, "Area"),
                buildTextField(cityController, "City"),
                buildTextField(stateController, "State"),
                buildTextField(pincodeController, "Pincode"),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    if (addressDoc == null) {
                      addAddress();
                    } else {
                      updateAddress(addressDoc.id);
                    }
                  },
                  child: Text(
                      addressDoc == null ? "Save Address" : "Update Address"),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("My Addresses"),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: showAddAddressDialog,
            child: const Icon(Icons.add),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('addresses')
                .orderBy("createdAt", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var addresses = snapshot.data!.docs;

              if (addresses.isEmpty) {
                return const Center(child: Text("No Address Added"));
              }

              return ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  var data = addresses[index];

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          Text("📞 ${data['phone']}"),
                          Text(
                              "${data['houseNo']}, ${data['street']}, ${data['area']}"),
                          Text(
                              "${data['city']} - ${data['pincode']}, ${data['state']}"),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              if (data['isDefault'])
                                const Chip(
                                  label: Text("Default"),
                                  backgroundColor: Colors.green,
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                              const Spacer(),

                              // 🔥 EDIT BUTTON
                              IconButton(
                                onPressed: () =>
                                    showAddAddressDialog(addressDoc: data),
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                              ),

                              if (!data['isDefault'])
                                TextButton(
                                  onPressed: () => setDefaultAddress(data.id),
                                  child: const Text("Make Default"),
                                ),

                              IconButton(
                                onPressed: () =>
                                    deleteAddress(data.id, data['isDefault']),
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        // 🔥 FULL SCREEN LOADER
        if (_isLoading)
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
