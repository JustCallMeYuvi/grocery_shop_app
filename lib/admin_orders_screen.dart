import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_tracking_step_widget.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  // 🔥 Update Order Status
  // Future<void> updateStatus(String orderId, String newStatus) async {
  //   await FirebaseFirestore.instance
  //       .collection('orders')
  //       .doc(orderId)
  //       .update({'status': newStatus});
  // }

  // Future<void> updateStatus(String orderId, String newStatus) async {
  //   await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
  //     'status': newStatus,
  //     'statusHistory.$newStatus': FieldValue.serverTimestamp(),
  //   });
  // }

  // 🔥 UPDATE STATUS + GENERATE OTP
  Future<void> updateStatus(String orderId, String newStatus) async {
    Map<String, dynamic> updateData = {
      'status': newStatus,
      'statusHistory.$newStatus': FieldValue.serverTimestamp(),
    };

    // 🔥 Generate OTP when Shipped
    if (newStatus == "Shipped") {
      String otp =
          (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();

      updateData['deliveryOtp'] = otp;
      updateData['otpVerified'] = false;
    }

    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update(updateData);
  }

  // 🔥 Delete Order With Confirmation + Loader
  Future<void> deleteOrder(BuildContext context, String orderId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Order"),
        content: const Text(
            "Are you sure you want to permanently delete this order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();

    if (!context.mounted) return;

    Navigator.of(context, rootNavigator: true).pop(); // close loader safely

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order Deleted Successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Orders"),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        double width = constraints.maxWidth;
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong"));
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final orders = snapshot.data!.docs;

            if (orders.isEmpty) {
              return const Center(
                child: Text("No Orders Found"),
              );
            }

            // 📱 MOBILE
            if (width < 900) {
              return _buildMobileList(orders);
            }

            // 💻 WEB
            return _buildWebGrid(orders, width);
            // return

            // ListView.builder(
            //   padding: const EdgeInsets.all(15),
            //   itemCount: orders.length,
            //   itemBuilder: (context, index) {
            //     final order = orders[index];
            //     final data = order.data() as Map<String, dynamic>;

            //     final total = (data['total'] ?? 0).toDouble();
            //     final status = data['status'] ?? "Placed";
            //     final userEmail = data['userEmail'] ?? "Unknown";
            //     final createdAt = (data['createdAt'] as Timestamp).toDate();

            //     return Card(
            //       margin: const EdgeInsets.only(bottom: 15),
            //       elevation: 4,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(15),
            //       ),
            //       child: ExpansionTile(
            //         title: Text(
            //           "Order: ${order.id.substring(0, 8)}",
            //           style: const TextStyle(fontWeight: FontWeight.bold),
            //         ),
            //         subtitle: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text("Customer: $userEmail"),
            //             Text("Total: ₹${total.toStringAsFixed(2)}"),
            //             Text(
            //               "Status: $status",
            //               style: TextStyle(
            //                 color: status == "Delivered"
            //                     ? Colors.green
            //                     : Colors.orange,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //             Text(
            //               "Date: ${createdAt.day}/${createdAt.month}/${createdAt.year}",
            //               style: const TextStyle(fontSize: 12),
            //             ),
            //           ],
            //         ),
            //         children: [
            //           /// 🔥 Status Dropdown
            //           Padding(
            //             padding: const EdgeInsets.symmetric(horizontal: 15),
            //             // child: buildStatusButtons(context, order.id, status),
            //             child:
            //                 buildOrderTracking(context, order.id, status, data),
            //           ),

            //           /// 🔥 Delete Button
            //           Padding(
            //             padding: const EdgeInsets.symmetric(horizontal: 15),
            //             child: Align(
            //               alignment: Alignment.centerRight,
            //               child: IconButton(
            //                 icon: const Icon(Icons.delete, color: Colors.red),
            //                 onPressed: () => deleteOrder(context, order.id),
            //               ),
            //             ),
            //           ),

            //           const Divider(),

            //           /// 🔥 Items List
            //           Padding(
            //             padding: const EdgeInsets.all(10),
            //             child: Column(
            //               children: (data['items'] as Map<String, dynamic>)
            //                   .entries
            //                   .map((entry) {
            //                 final item = entry.value;
            //                 return ListTile(
            //                   title: Text(item['name']),
            //                   subtitle:
            //                       Text("₹${item['price']} x ${item['qty']}"),
            //                   trailing: Text(
            //                     "₹${item['price'] * item['qty']}",
            //                     style:
            //                         const TextStyle(fontWeight: FontWeight.bold),
            //                   ),
            //                 );
            //               }).toList(),
            //             ),
            //           )
            //         ],
            //       ),
            //     );
            //   },
            // );
          },
        );
      }),
    );
  }

  Widget buildOrderTracking(
    BuildContext context,
    String orderId,
    String currentStatus,
    Map<String, dynamic> data,
  ) {
    final List<String> orderSteps = [
      "Placed",
      "Packed",
      "Shipped",
      "Delivered"
    ];

    // 🔥 READ STATUS HISTORY
    Map<String, dynamic> history = data['statusHistory'] ?? {};

    int currentIndex = orderSteps.indexOf(currentStatus);

    return buildGlassCard(
      title: "Order Tracking",
      child: Column(
        children: orderSteps.asMap().entries.map((entry) {
          int index = entry.key;
          String step = entry.value;

          bool isCompleted = index <= currentIndex;
          bool isCurrent =
              index == currentIndex && currentIndex != orderSteps.length - 1;
          bool isLast = index == orderSteps.length - 1;
          bool isNext = index == currentIndex + 1;

          // 🔥 GET TIME FROM FIRESTORE
          Timestamp? timeStamp = history[step];
          DateTime? time = timeStamp != null ? timeStamp.toDate() : null;

          String? formattedTime;

          if (time != null) {
            formattedTime =
                "${time.day}/${time.month}/${time.year}  ${time.hour}:${time.minute.toString().padLeft(2, '0')}";
          }

          return GestureDetector(
            onTap: isNext
                ? () async {
                    // 🔥 IF NEXT STEP IS DELIVERED → VERIFY OTP
                    if (step == "Delivered") {
                      TextEditingController otpController =
                          TextEditingController();

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Verify Delivery OTP"),
                          content: TextField(
                            controller: otpController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Enter Customer OTP",
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                String enteredOtp = otpController.text.trim();
                                String correctOtp = data['deliveryOtp'] ?? "";

                                // if (enteredOtp == correctOtp) {
                                //   await FirebaseFirestore.instance
                                //       .collection('orders')
                                //       .doc(orderId)
                                //       .update({
                                //     'status': "Delivered",
                                //     'otpVerified': true,
                                //     'statusHistory.Delivered':
                                //         FieldValue.serverTimestamp(),
                                //   });

                                //   Navigator.pop(context);
                                // }

                                if (enteredOtp == correctOtp) {
                                  // 🔥 1. Update Firestore
                                  await FirebaseFirestore.instance
                                      .collection('orders')
                                      .doc(orderId)
                                      .update({
                                    'status': "Delivered",
                                    'otpVerified': true,
                                    'statusHistory.Delivered':
                                        FieldValue.serverTimestamp(),
                                  });

                                  // 🔥 2. Get Order Document
                                  DocumentSnapshot orderDoc =
                                      await FirebaseFirestore.instance
                                          .collection('orders')
                                          .doc(orderId)
                                          .get();

                                  String userId = orderDoc[
                                      'userId']; // Make sure this exists

                                  // 🔥 3. Get Customer FCM Token
                                  DocumentSnapshot userDoc =
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(userId)
                                          .get();

                                  String token = userDoc['fcmToken'];

                                  print("Customer Token: $token");

                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Invalid OTP")),
                                  );
                                }
                              },
                              child: const Text("Verify"),
                            ),
                          ],
                        ),
                      );

                      return;
                    }
                    bool confirm = await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Update Order Status"),
                            content: Text("Move order to '$step'?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Confirm"),
                              ),
                            ],
                          ),
                        ) ??
                        false;

                    if (confirm) {
                      await updateStatus(orderId, step);
                    }
                  }
                : null,
            child: TrackingStep(
              title: step,
              subtitle: formattedTime, // 🔥 SHOW TIME HERE
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLast: isLast,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildGlassCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          child,
        ],
      ),
    );
  }

  Widget _buildMobileList(List orders) {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(context, orders[index], isWeb: false);
      },
    );
  }

  Widget _buildWebGrid(List orders, double width) {
    return GridView.builder(
      padding: const EdgeInsets.all(25),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 25,
        mainAxisSpacing: 25,
        mainAxisExtent: 420, // 👈 enough height for tracking
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(context, orders[index], isWeb: true);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, DocumentSnapshot order,
      {required bool isWeb}) {
    final data = order.data() as Map<String, dynamic>;

    final total = (data['total'] ?? 0).toDouble();
    final status = data['status'] ?? "Placed";
    final userEmail = data['userEmail'] ?? "Unknown";
    final createdAt = (data['createdAt'] as Timestamp).toDate();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          // 🔥 Prevent overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Order: ${order.id.substring(0, 8)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text("Customer: $userEmail"),
              Text("Total: ₹${total.toStringAsFixed(2)}"),
              Text(
                "Status: $status",
                style: TextStyle(
                  color: status == "Delivered" ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Date: ${createdAt.day}/${createdAt.month}/${createdAt.year}",
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 10),
              buildOrderTracking(context, order.id, status, data),
              const Divider(),
              Column(
                children: (data['items'] as Map<String, dynamic>)
                    .entries
                    .map((entry) {
                  final item = entry.value;
                  return ListTile(
                    dense: true,
                    title: Text(item['name']),
                    subtitle: Text("₹${item['price']} x ${item['qty']}"),
                    trailing: Text(
                      "₹${item['price'] * item['qty']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteOrder(context, order.id),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
