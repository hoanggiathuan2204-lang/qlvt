import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String subTitle;
  final IconData icon;
  final Color color;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.subTitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Tạo màu nền icon từ color gốc, alpha = 30 (≈12%)
    final iconBg = Color.fromARGB(30, color.red, color.green, color.blue);
    final shadowColor = Color.fromARGB(30, color.red, color.green, color.blue);
    final borderColor = Color.fromARGB(30, color.red, color.green, color.blue);

    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //─── Icon row ──────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),

          const SizedBox(height: 16),

          //─── Value ─────────────────────────────
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 4),

          //─── Title ─────────────────────────────
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xff1F2937),
            ),
          ),

          const SizedBox(height: 2),

          //─── Sub label ─────────────────────────
          Text(
            subTitle,
            style: const TextStyle(fontSize: 12, color: Color(0xff9CA3AF)),
          ),
        ],
      ),
    );
  }
}
