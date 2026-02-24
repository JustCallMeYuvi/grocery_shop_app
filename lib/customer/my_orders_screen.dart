import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
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
              child: Text(
                "No Orders Yet 📦",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              // final data = order.data() as Map<String, dynamic>;
              // ✅ DEFINE data properly
              final data = order.data() as Map<String, dynamic>;

              final items = data['items'] as Map<String, dynamic>;

              final itemNames =
                  items.values.map((item) => item['name'].toString()).toList();

              String productTitle = "";

              if (itemNames.length == 1) {
                productTitle = itemNames.first;
              } else if (itemNames.length > 1) {
                productTitle =
                    "${itemNames.first} + ${itemNames.length - 1} more";
              }

              final total = data['total'] ?? 0;
              final status = data['status'] ?? "Placed";
              final createdAt = (data['createdAt'] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ExpansionTile(
                  title: Text(
                    "Order ID: ${order.id.substring(0, 8)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name: $productTitle',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text("Total: ₹${total.toStringAsFixed(2)}"),
                      const SizedBox(height: 4),
                      Text(
                        "Status: $status",
                        style: TextStyle(
                          color: status == "Delivered"
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Date: ${createdAt.day}/${createdAt.month}/${createdAt.year}",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  children: [
                    /// 🔥 ORDER TIMELINE
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: buildOrderTimeline(status, data),
                    ),

                    // 🔥 ADD OTP SHOW CODE HERE
                    if (status == "Shipped" && data['otpVerified'] == false)
                      Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Delivery OTP",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['deliveryOtp'] ?? "",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 5,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: (data['items'] as Map<String, dynamic>)
                            .entries
                            .map((entry) {
                          final item = entry.value;
                          return ListTile(
                            title: Text(item['name']),
                            subtitle:
                                Text("₹${item['price']} x ${item['qty']}"),
                            trailing: Text(
                              "₹${item['price'] * item['qty']}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildOrderTimeline(
    String status,
    Map<String, dynamic> data,
  ) {
    List<String> stages = ["Placed", "Packed", "Shipped", "Delivered"];

    int currentIndex = stages.indexOf(status);

    // 🔥 GET STATUS HISTORY
    Map<String, dynamic> history = data['statusHistory'] ?? {};

    return Column(
      children: stages.asMap().entries.map((entry) {
        int index = entry.key;
        String stage = entry.value;

        bool isCompleted = index <= currentIndex;

        // 🔥 GET TIME
        Timestamp? timeStamp = history[stage];
        DateTime? time = timeStamp != null ? timeStamp.toDate() : null;

        String? formattedTime;

        if (time != null) {
          formattedTime =
              "${time.day}/${time.month}/${time.year}  ${time.hour}:${time.minute.toString().padLeft(2, '0')}";
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isCompleted ? Colors.green : Colors.grey,
                ),
                if (index != stages.length - 1)
                  Container(
                    height: 45,
                    width: 2,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.green : Colors.grey,
                      ),
                    ),

                    // 🔥 SHOW TIME
                    if (formattedTime != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          formattedTime,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
