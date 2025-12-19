import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../core/constants/app_strings.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService;

  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);

  SettingsProvider(this._storageService);

  bool get notificationsEnabled => _notificationsEnabled;
  TimeOfDay get notificationTime => _notificationTime;

  String get notificationTimeString {
    final hour = _notificationTime.hour.toString().padLeft(2, '0');
    final minute = _notificationTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> init() async {
    _notificationsEnabled = _storageService.getBool(AppStrings.notificationsKey) ?? false;

    final savedTime = _storageService.getString(AppStrings.notificationTimeKey);
    if (savedTime != null) {
      final parts = savedTime.split(':');
      if (parts.length == 2) {
        _notificationTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 9,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _storageService.setBool(AppStrings.notificationsKey, value);
    notifyListeners();
  }

  Future<void> setNotificationTime(TimeOfDay time) async {
    _notificationTime = time;
    final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    await _storageService.setString(AppStrings.notificationTimeKey, timeString);
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    await setNotificationsEnabled(!_notificationsEnabled);
  }
}
