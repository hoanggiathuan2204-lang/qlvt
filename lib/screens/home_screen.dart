import 'package:flutter/material.dart';

import '../data/app_data.dart';

import 'dashboard_screen.dart';
import 'material_screen.dart';
import 'supplier_screen.dart';
import 'product_screen.dart';
import 'delivery_history_screen.dart';
import 'report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final materialController = AppData.materialController;

  final productController = AppData.productController;

  Future<void> openPage(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));

    if (mounted) {
      setState(() {});
    }
  }

  Widget menu(IconData icon, String title, Color color, Widget page) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          openPage(page);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 28),
            ),

            const SizedBox(height: 12),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoCard({
    required IconData icon,
    required String title,
    required Future<int> future,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),

            const SizedBox(height: 8),

            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),

            FutureBuilder<int>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    '0',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                return Text(
                  snapshot.data.toString(),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hệ thống quản lý vật tư"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            //------------------------------------
            // Header
            //------------------------------------
            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),

              child: const Row(
                children: [
                  CircleAvatar(radius: 25, child: Icon(Icons.person)),

                  SizedBox(width: 15),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Xin chào!", style: TextStyle(color: Colors.grey)),

                      SizedBox(height: 4),

                      Text(
                        "Chào mừng đến hệ thống Quản lý vật tư",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            //------------------------------------
            // Thống kê
            //------------------------------------
            Row(
              children: [
                Expanded(
                  child: infoCard(
                    icon: Icons.inventory,
                    title: "Tổng vật tư",
                    future: materialController.totalMaterial(),
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: infoCard(
                    icon: Icons.factory,
                    title: "Thành phẩm",
                    future: productController.totalProduct(),
                    color: Colors.green,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: infoCard(
                    icon: Icons.warning_amber,
                    title: "Cảnh báo",
                    future: materialController.warningMaterial(),
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            //------------------------------------
            // Menu
            //------------------------------------
            Expanded(
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),

                crossAxisCount: 3,

                crossAxisSpacing: 15,

                mainAxisSpacing: 15,

                childAspectRatio: 1.35,

                children: [
                  menu(
                    Icons.dashboard,
                    "Dashboard",
                    Colors.indigo,
                    const DashboardScreen(),
                  ),

                  menu(
                    Icons.inventory,
                    "Quản lý vật tư",
                    Colors.blue,
                    const MaterialScreen(),
                  ),

                  menu(
                    Icons.people,
                    "Nhà cung cấp",
                    Colors.green,
                    const SupplierScreen(),
                  ),

                  menu(
                    Icons.factory,
                    "Quản lý thành phẩm",
                    Colors.orange,
                    const ProductScreen(),
                  ),

                  menu(
                    Icons.local_shipping,
                    "Lịch sử giao hàng",
                    Colors.red,
                    const DeliveryHistoryScreen(),
                  ),

                  menu(
                    Icons.bar_chart,
                    "Thống kê",
                    Colors.purple,
                    const ReportScreen(),
                  ),

                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Color(0xfffde2e2),
                            child: Icon(Icons.logout, color: Colors.red),
                          ),

                          SizedBox(height: 12),

                          Text(
                            "Đăng xuất",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
