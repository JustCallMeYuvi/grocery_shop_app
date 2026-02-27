import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_shop_app/admin_orders_screen.dart';
import 'package:grocery_shop_app/auth_screen.dart';
import 'product_screen.dart';
import 'billing_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              bool? confirmLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirm Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );

              if (confirmLogout == true) {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildTopBanner(width),
                        _buildAnalyticsSection(),
                        lowStockAlert(),
                        const SizedBox(height: 30),
                        _buildResponsiveCards(context, width),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= TOP BANNER =================

  Widget _buildTopBanner(double width) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              "https://images.unsplash.com/photo-1601597111158-2fceff292cdc",
              height: width > 900 ? 250 : 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Grocery Shop Management",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= RESPONSIVE CARDS =================

  Widget _buildResponsiveCards(BuildContext context, double width) {
    int crossAxisCount = 1;

    if (width > 1000) {
      crossAxisCount = 3;
    } else if (width > 700) {
      crossAxisCount = 2;
    }

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 30,
        mainAxisSpacing: 30,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        // childAspectRatio: width > 900 ? 1.4 : 2.5,
        childAspectRatio: width > 900 ? 1.2 : 1.6,
        children: [
          _buildCard(
            context,
            title: "Manage Products",
            icon: Icons.inventory,
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductScreen()),
              );
            },
          ),
          _buildCard(
            context,
            title: "Billing",
            icon: Icons.point_of_sale,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BillingScreen()),
              );
            },
          ),
          _buildCard(
            context,
            title: "Customer Orders",
            icon: Icons.receipt_long,
            color: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminOrdersScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ================= CARD UI =================

  Widget _buildCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          );
        }

        final orders = snapshot.data!.docs;

        double totalRevenue = 0;
        int todayOrders = 0;
        Map<String, int> productSales = {};

        DateTime today = DateTime.now();

        for (var order in orders) {
          final data = order.data() as Map<String, dynamic>;

          totalRevenue += (data['total'] ?? 0).toDouble();

          DateTime createdAt = (data['createdAt'] as Timestamp).toDate();

          if (createdAt.year == today.year &&
              createdAt.month == today.month &&
              createdAt.day == today.day) {
            todayOrders++;
          }

          Map<String, dynamic> items = data['items'] as Map<String, dynamic>;

          for (var item in items.values) {
            String name = item['name'];
            int qty = item['qty'];
            productSales[name] = (productSales[name] ?? 0) + qty;
          }
        }

        String topProduct = "No Sales";

        if (productSales.isNotEmpty) {
          topProduct = productSales.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 1;

              if (constraints.maxWidth > 1000) {
                crossAxisCount = 3;
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 2;
              }
              final analyticsData = [
                {
                  "title": "Total Revenue",
                  "value": "₹${totalRevenue.toStringAsFixed(0)}",
                  "icon": Icons.currency_rupee,
                  "color": Colors.green,
                },
                {
                  "title": "Orders Today",
                  "value": "$todayOrders",
                  "icon": Icons.today,
                  "color": Colors.blue,
                },
                {
                  "title": "Top Product",
                  "value": topProduct,
                  "icon": Icons.star,
                  "color": Colors.orange,
                },
              ];
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: analyticsData.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 2.2,
                ),
                itemBuilder: (context, index) {
                  final item = analyticsData[index];

                  return _analyticsCard(
                    item["title"] as String,
                    item["value"] as String,
                    item["icon"] as IconData,
                    item["color"] as Color,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _analyticsCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget lowStockAlert() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('qty', isLessThan: 5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox();
        }

        final lowStock = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      "Low Stock Alert",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...lowStock.map((doc) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 8, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${doc['name']} (Qty: ${doc['qty']})",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList()
              ],
            ),
          ),
        );
      },
    );
  }
}
