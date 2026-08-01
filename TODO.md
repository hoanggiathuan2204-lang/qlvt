# TODO - Fix Responsive & Add Notification System

## Part 1: Fix Responsive Mobile Web
- [x] Step 1.1: Fix `web/index.html` - Add viewport meta tag for mobile
- [x] Step 1.2: Update `web/manifest.json` - Ensure responsive display
- [x] Step 1.3: Update `lib/widgets/dashboard_header.dart` - Show notification bell on mobile too

## Part 2: Build Notification System
- [x] Step 2.1: Create `lib/models/notification_model.dart` - Notification model
- [x] Step 2.2: Update `lib/services/firestore_data_service.dart` - Add notifications collection, addNotification(), streamNotifications()
- [x] Step 2.3: Update all CRUD methods in FirestoreDataService to log notifications
- [x] Step 2.4: Create `lib/widgets/notification_panel.dart` - Notification panel widget
- [x] Step 2.5: Update `lib/widgets/dashboard_header.dart` - Integrate notification bell with badge + dropdown overlay
- [x] Step 2.6: Update controllers - Add import/export notifications

## Part 3: Verify
- [x] Verify build compiles successfully (flutter analyze passes with zero errors)
- [x] Clean up unused `_titles` and `_i` variable warnings in app_shell.dart
