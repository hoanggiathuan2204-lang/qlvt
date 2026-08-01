/// Represents a notification event logged to Firestore
/// when a user performs a CRUD operation in the app.
class NotificationModel {
  final String id;
  final String action; // 'add', 'update', 'delete', 'import', 'export'
  final String description; // Human-readable description
  final String userName; // username of the actor
  final String displayName; // display name of the actor
  final String userRole; // role of the actor
  final DateTime timestamp;
  final String targetType; // 'material', 'product', 'supplier', 'delivery'
  final String targetId; // ID of the target record
  final String targetName; // Name of the target record for display

  NotificationModel({
    required this.id,
    required this.action,
    required this.description,
    required this.userName,
    required this.displayName,
    required this.userRole,
    required this.timestamp,
    required this.targetType,
    required this.targetId,
    required this.targetName,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: _toString(map['id']),
      action: _toString(map['action']),
      description: _toString(map['description']),
      userName: _toString(map['userName']),
      displayName: _toString(map['displayName']),
      userRole: _toString(map['userRole']),
      timestamp: _toDate(map['timestamp']) ?? DateTime.now(),
      targetType: _toString(map['targetType']),
      targetId: _toString(map['targetId']),
      targetName: _toString(map['targetName']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action': action,
      'description': description,
      'userName': userName,
      'displayName': displayName,
      'userRole': userRole,
      'timestamp': timestamp.toIso8601String(),
      'targetType': targetType,
      'targetId': targetId,
      'targetName': targetName,
    };
  }

  /// Returns a short single-line summary for notification list display.
  String get summary {
    return '$displayName ${actionLabel(action)} $targetName';
  }

  /// Returns a detailed description for tooltip or expanded view.
  String get detail {
    return '$displayName ($userName - $userRole) ${actionLabel(action)} "$targetName" ($targetType)';
  }

  static String actionLabel(String action) {
    switch (action) {
      case 'add':
        return 'đã thêm';
      case 'update':
        return 'đã cập nhật';
      case 'delete':
        return 'đã xóa';
      case 'import':
        return 'đã nhập kho';
      case 'export':
        return 'đã xuất kho';
      case 'deliver':
        return 'đã giao hàng';
      default:
        return 'đã thao tác';
    }
  }

  /// Returns the icon name for the action type.
  static String actionIcon(String action) {
    switch (action) {
      case 'add':
        return 'add_circle';
      case 'update':
        return 'edit';
      case 'delete':
        return 'delete';
      case 'import':
        return 'download';
      case 'export':
        return 'upload';
      case 'deliver':
        return 'local_shipping';
      default:
        return 'notifications';
    }
  }

  static String _toString(dynamic value) {
    if (value is String) return value;
    if (value == null) return '';
    return value.toString();
  }

  static DateTime? _toDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    // Handle Firestore Timestamp-like objects that expose toDate()
    try {
      final dt = (value as dynamic).toDate();
      if (dt is DateTime) return dt;
    } catch (_) {}
    return null;
  }
}
