import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/firestore_data_service.dart';
import '../theme/app_colors.dart';
import 'notification_panel.dart';

class DashboardHeader extends StatefulWidget {
  final String title;
  final String userName;
  final VoidCallback? onMenuTap; // For mobile hamburger menu

  const DashboardHeader({
    super.key,
    required this.title,
    required this.userName,
    this.onMenuTap,
  });

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  int _notificationCount = 0;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _subscribeToNotifications();
  }

  void _subscribeToNotifications() {
    FirestoreDataService.streamNotifications().listen((list) {
      if (mounted) {
        setState(() => _notificationCount = list.length);
      }
    }, onError: (_) {});
  }

  void _toggleNotificationOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        final panelWidth = isMobile ? screenWidth - 32.0 : 340.0;
        final offsetX = isMobile ? -8.0 : -280.0;

        return GestureDetector(
          onTap: () {
            _overlayEntry?.remove();
            _overlayEntry = null;
          },
          child: Material(
            color: Colors.transparent,
            child: CompositedTransformFollower(
              link: _layerLink,
              offset: Offset(offsetX, 56.0),
              targetAnchor: Alignment.topRight,
              followerAnchor: Alignment.topRight,
              child: Container(
                width: panelWidth,
                constraints: BoxConstraints(maxHeight: 420, maxWidth: screenWidth),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: NotificationPanel(
                    asOverlay: true,
                    onClose: () {
                      _overlayEntry?.remove();
                      _overlayEntry = null;
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static String _formatDate(DateTime dt) {
    const days = [
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];
    final dayName = days[dt.weekday - 1];
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$dayName, $d/$m/${dt.year}';
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: isMobile ? 56 : 72,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            //─── Hamburger menu (mobile only) ──────
            if (isMobile && widget.onMenuTap != null) ...[
              GestureDetector(
                onTap: widget.onMenuTap,
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_rounded,
                    size: 22,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],

            //─── Title + date ───────────────────────
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isMobile)
                    Text(
                      _formatDate(now),
                      style: const TextStyle(
                        color: AppColors.subText,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),

            //─── Notification bell (always visible) ──
            _notificationBell(),

            // Quick test notification (small button) — helpful for E2E testing on web/desktop
            IconButton(
              tooltip: 'Test thông báo',
              icon: const Icon(
                Icons.add_alert_outlined,
                size: 20,
                color: AppColors.subText,
              ),
              onPressed: () async {
                try {
                  await FirestoreDataService.addNotification(
                    action: 'test',
                    description: 'Thông báo kiểm tra từ UI',
                    targetType: 'test',
                    targetId: DateTime.now().millisecondsSinceEpoch.toString(),
                    targetName: 'Kiểm tra',
                  );
                } catch (_) {}
              },
            ),

            const SizedBox(width: 8),

            //─── Avatar + tên ───────────────────────
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8 : 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: isMobile ? 12 : 16,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      widget.userName.isNotEmpty
                          ? widget.userName[0].toUpperCase()
                          : 'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 10 : 13,
                      ),
                    ),
                  ),
                  if (!isMobile) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        AuthService.instance.currentUser?.displayName ??
                            widget.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.text,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.subText,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationBell() {
    return GestureDetector(
      onTap: _toggleNotificationOverlay,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              size: 22,
              color: AppColors.subText,
            ),
            if (_notificationCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    _notificationCount > 99 ? '99+' : '$_notificationCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
