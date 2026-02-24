// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:grocery_shop_app/admin_orders_screen.dart';
// import 'package:grocery_shop_app/auth_screen.dart';
// import 'product_screen.dart';
// import 'billing_screen.dart';

// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Dashboard"),
//         backgroundColor: const Color(0xFF2E7D32),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               bool? confirmLogout = await showDialog<bool>(
//                 context: context,
//                 builder: (context) {
//                   return AlertDialog(
//                     title: const Text("Confirm Logout"),
//                     content: const Text("Are you sure you want to logout?"),
//                     actions: [
//                       TextButton(
//                         onPressed: () {
//                           Navigator.pop(context, false); // Cancel
//                         },
//                         child: const Text("Cancel"),
//                       ),
//                       ElevatedButton(
//                         onPressed: () {
//                           Navigator.pop(context, true); // Confirm
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red,
//                         ),
//                         child: const Text("Logout"),
//                       ),
//                     ],
//                   );
//                 },
//               );

//               if (confirmLogout == true) {
//                 await FirebaseAuth.instance.signOut();

//                 Navigator.of(context).pushAndRemoveUntil(
//                   MaterialPageRoute(builder: (_) => const AuthScreen()),
//                   (route) => false,
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // 🔥 Top Banner Image
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(20),
//                       child: Image.network(
//                         "https://images.unsplash.com/photo-1601597111158-2fceff292cdc",
//                         height: 180,
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     const SizedBox(height: 15),
//                     const Text(
//                       "Grocery Shop Management",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // 🔥 Cards Section
//               Expanded(
//                 child: Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.vertical(
//                       top: Radius.circular(30),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       _buildCard(
//                         context,
//                         title: "Manage Products",
//                         icon: Icons.inventory,
//                         color: Colors.orange,
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => const ProductScreen(),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 20),
//                       _buildCard(
//                         context,
//                         title: "Billing",
//                         icon: Icons.point_of_sale,
//                         color: Colors.blue,
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => const BillingScreen(),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(
//                         height: 20,
//                       ),
//                       _buildCard(
//                         context,
//                         title: "Customer Orders",
//                         icon: Icons.receipt_long,
//                         color: Colors.purple,
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => const AdminOrdersScreen(),
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCard(BuildContext context,
//       {required String title,
//       required IconData icon,
//       required Color color,
//       required VoidCallback onTap}) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         height: 100,
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.2),
//               blurRadius: 10,
//               offset: const Offset(0, 5),
//             )
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             Icon(icon, size: 40, color: color),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             const Icon(Icons.arrow_forward_ios)
//           ],
//         ),
//       ),
//     );
//   }
// }



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
                  content:
                      const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context, true),
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
                  MaterialPageRoute(
                      builder: (_) => const AuthScreen()),
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
                colors: [
                  Color(0xFF4CAF50),
                  Color(0xFF2E7D32)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: 1200),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildTopBanner(width),
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

  Widget _buildResponsiveCards(
      BuildContext context, double width) {
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
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(30)),
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
                MaterialPageRoute(
                    builder: (_) => const ProductScreen()),
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
                MaterialPageRoute(
                    builder: (_) => const BillingScreen()),
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
                MaterialPageRoute(
                    builder: (_) =>
                        const AdminOrdersScreen()),
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
}