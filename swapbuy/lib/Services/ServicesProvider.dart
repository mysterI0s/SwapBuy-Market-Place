import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServicesProvider with ChangeNotifier {
  SharedPreferences? _prefs;

  /// تحميل SharedPreferences داخل init
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  int get userid => _prefs?.getInt('id') ?? 0;

  int get id_request => _prefs?.getInt('id_request') ?? 0;

  int? get deliveryId => _prefs?.getInt('id');

  String get role => _prefs?.getString('role') ?? '';

  bool get isLoggedIn => _prefs?.getBool('isLoggin') ?? false;

  int get userIdForChat => _prefs?.getInt('user_id_for_chat') ?? 0;

  Future<void> saveUserIDAndRole(int id, String role) async {
    await _prefs?.setInt('id', id);
    await _prefs?.setString('role', role);
    await _prefs?.setBool('isLoggin', true);
    notifyListeners();
  }

  Future<void> saveDeliveryIDAndRole(
    int id,
    int idrequest,
    String role,
    bool isloggin,
  ) async {
    await _prefs?.setInt('id', id);
    await _prefs?.setInt('id_request', idrequest);
    await _prefs?.setString('role', role);
    await _prefs?.setBool('isLoggin', isloggin);
    notifyListeners();
  }

  Future<void> logout() async {
    await _prefs?.remove('id');
    await _prefs?.remove('role');
    await _prefs?.remove('id_request');
    await _prefs?.remove('isLoggin');
    notifyListeners();
  }

  Future<void> saveUserIdForChat(int userId) async {
    await _prefs?.setInt('user_id_for_chat', userId);
    notifyListeners();
  }
}
