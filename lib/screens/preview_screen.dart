import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'dashboard_screen.dart';

/// A simple preview screen that renders a phone-sized `DashboardScreen`
/// side-by-side with the desktop `AppShell` so the web deployment shows
/// both mobile and desktop views together (as requested).
class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          final phoneWidth = width * 0.38; // left column approx phone
          final desktopWidth = width - phoneWidth - 24;

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Phone preview
                Container(
                  width: phoneWidth.clamp(300.0, 420.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 8)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Column(
                      children: [
                        // top bezel
                        Container(height: 10, color: Colors.black12),
                        Expanded(
                          child: DashboardScreen(showSidebar: false),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Desktop preview (fills remaining)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 8)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Row(children: [
                        // Use AppShell but force a wider layout by embedding it
                        Expanded(child: AppShell()),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
