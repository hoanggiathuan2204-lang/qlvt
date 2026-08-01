import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../theme/app_colors.dart';
import '../services/firestore_data_service.dart';

/// A panel widget that displays real-time notifications from Firestore.
/// Can be used in a dropdown overlay, a full-screen page, or a dialog.
class NotificationPanel extends StatefulWidget {
  final bool asOverlay; // If true, shows as a compact overlay (for header bell)
  final VoidCallback? onClose;

  const NotificationPanel({super.key, this.asOverlay = false, this.onClose});

  @override
  State<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<NotificationPanel> {
  List<NotificationModel> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _subscribeToNotifications();
  }

  void _subscribeToNotifications() {
    FirestoreDataService.streamNotifications().listen(
      (list) {
        if (mounted) {
          setState(() {
            _notifications = list;
            _loading = false;
          });
        }
      },
      onError: (e) {
        if (mounted) {
          setState(() => _loading = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_off_outlined,
                size: 48,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 12),
              const Text(
                'Chưa có thông báo nào',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (widget.asOverlay) {
      return _buildOverlayList();
    }

    return _buildFullList();
  }

  Widget _buildOverlayList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.notifications, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Thông báo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                '${_notifications.length}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        // Notification list (max 5 items for overlay)
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: _notifications.length > 5 ? 5 : _notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
            itemBuilder: (_, i) => _buildNotificationTile(_notifications[i]),
          ),
        ),
        // View all button if >5 items
        if (_notifications.length > 5)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: TextButton(
              onPressed: () => _showAllNotifications(context),
              child: Text(
                'Xem tất cả (${_notifications.length})',
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFullList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.notifications, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Lịch sử thao tác',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${_notifications.length} thông báo',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: _notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
            itemBuilder: (_, i) => _buildNotificationTile(_notifications[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationTile(NotificationModel notification) {
    IconData icon;
    Color iconColor;

    switch (notification.action) {
      case 'add':
        icon = Icons.add_circle_outline;
        iconColor = Colors.green;
        break;
      case 'update':
        icon = Icons.edit_outlined;
        iconColor = Colors.blue;
        break;
      case 'delete':
        icon = Icons.delete_outline;
        iconColor = Colors.red;
        break;
      case 'import':
        icon = Icons.download_outlined;
        iconColor = AppColors.primary;
        break;
      case 'export':
        icon = Icons.upload_outlined;
        iconColor = Colors.orange;
        break;
      case 'deliver':
        icon = Icons.local_shipping_outlined;
        iconColor = Colors.purple;
        break;
      default:
        icon = Icons.notifications_outlined;
        iconColor = Colors.grey;
    }

    return InkWell(
      onTap: () => _showNotificationDetail(context, notification),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.summary,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(notification.timestamp),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            // Role badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _roleColor(
                  notification.userRole,
                ).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _roleLabel(notification.userRole),
                style: TextStyle(
                  fontSize: 10,
                  color: _roleColor(notification.userRole),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetail(
    BuildContext context,
    NotificationModel notification,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notifications, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Chi tiết thông báo', style: TextStyle(fontSize: 17)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Người thực hiện', notification.displayName),
            _detailRow('Tên đăng nhập', notification.userName),
            _detailRow('Vai trò', _roleLabel(notification.userRole)),
            _detailRow(
              'Thao tác',
              NotificationModel.actionLabel(notification.action),
            ),
            _detailRow('Đối tượng', notification.targetType),
            _detailRow('Tên', notification.targetName),
            _detailRow('Thời gian', _formatTimeDetail(notification.timestamp)),
            if (notification.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 4),
              Text(
                notification.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.subText,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text('Tất cả thông báo'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => setState(() {}),
              ),
            ],
          ),
          body: NotificationPanel(asOverlay: false),
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'owner':
        return Colors.amber.shade700;
      case 'accountant':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'owner':
        return 'Chủ';
      case 'accountant':
        return 'Kế toán';
      default:
        return 'User';
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';

    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/${dt.year} $h:$mi';
  }

  String _formatTimeDetail(DateTime dt) {
    final days = [
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
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$dayName, $d/$m/${dt.year} $h:$mi';
  }
}
