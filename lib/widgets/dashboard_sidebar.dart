import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';

class DashboardSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback? onCloseDrawer;

  const DashboardSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
    this.onCloseDrawer,
  });

  static const _menus = [
    _Menu(0, Icons.dashboard_rounded, 'Dashboard'),
    _Menu(1, Icons.inventory_2_rounded, 'Quản lý vật tư'),
    _Menu(2, Icons.business_rounded, 'Nhà cung cấp'),
    _Menu(3, Icons.factory_rounded, 'Thành phẩm'),
    _Menu(4, Icons.local_shipping_rounded, 'Lịch sử giao hàng'),
    _Menu(5, Icons.bar_chart_rounded, 'Báo cáo & Thống kê'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.sidebarWidth,
      color: AppColors.sidebar,
      child: Column(
        children: [
          //────────────────────────────────────
          // Logo & tên công ty
          //────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 18),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.change_history_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ÁNH DƯƠNG',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Hệ thống ERP',
                        style: TextStyle(
                          color: Color(0x80FFFFFF),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          //────────────────────────────────────
          // Menu items
          //────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              children: [
                const _SectionLabel('MENU CHÍNH'),
                ..._menus.map(
                  (m) => _MenuItem(
                    menu: m,
                    selected: selectedIndex == m.index,
                    onTap: () {
                      onSelect(m.index);
                      onCloseDrawer?.call();
                    },
                  ),
                ),
              ],
            ),
          ),

          //────────────────────────────────────
          // Đăng xuất
          //────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0x1AFFFFFF))),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 6,
              ),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0x26FF5252), // red 15%
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size: 20,
                ),
              ),
              title: const Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () async {
                await FirebaseService.signOut();
                AuthService.instance.logout();
                if (!context.mounted) return;
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Menu {
  final int index;
  final IconData icon;
  final String label;
  const _Menu(this.index, this.icon, this.label);
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0x4DFFFFFF), // white 30%
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final _Menu menu;
  final bool selected;
  final VoidCallback onTap;

  const _MenuItem({
    required this.menu,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // primary cam: 0xffF57C00 — dùng constant tránh withOpacity
    const selBg = Color(0x2EF57C00); // primary 18%
    const selBorder = Color(0x66F57C00); // primary 40%
    const selIcon = Color(0x40F57C00); // primary 25%
    const unselIcon = Color(0x0FFFFFFF); // white 6%

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: selected ? selBg : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: selected ? Border.all(color: selBorder) : null,
        ),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 2,
          ),
          leading: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: selected ? selIcon : unselIcon,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              menu.icon,
              size: 18,
              color: selected ? AppColors.primary : const Color(0x99FFFFFF),
            ),
          ),
          title: Text(
            menu.label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xB3FFFFFF),
              fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
              fontSize: 13.5,
            ),
          ),
          trailing: selected
              ? Container(
                  width: 4,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )
              : null,
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
