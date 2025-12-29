import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  String _aiModel = "Gemini 1.5 Pro";
  bool _pushNotificationsEnabled = true;

  String get aiModel => _aiModel;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;

  SettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _aiModel = prefs.getString('ai_model') ?? "Gemini 1.5 Pro";
    _pushNotificationsEnabled = prefs.getBool('push_notifications') ?? true;
    notifyListeners();
  }

  Future<void> setAIModel(String model) async {
    _aiModel = model;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_model', model);
  }

  Future<void> setPushNotifications(bool enabled) async {
    _pushNotificationsEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications', enabled);
  }
}
