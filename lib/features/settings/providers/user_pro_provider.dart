import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProNotifier extends Notifier<bool> {
  @override
  bool build() {
    _loadProStatus();
    return false;
  }

  Future<void> _loadProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('is_pro_user') ?? false;
  }

  Future<void> setProStatus(bool isPro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_pro_user', isPro);
    state = isPro;
  }
}

final userProProvider = NotifierProvider<UserProNotifier, bool>(UserProNotifier.new);
