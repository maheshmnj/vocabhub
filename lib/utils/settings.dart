import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/main.dart';

class Settings {
  static SharedPreferences? _sharedPreferences;
  static const signedInKey = 'isSignedIn';
  static const skipCountKey = 'skipCount';
  static const darkKey = 'isDark';
  static const maxSkipCount = 3;
  Settings() {
    init();
  }
  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  set dark(bool value) {
    _sharedPreferences!.setBool('isDark', value);
  }

  Future<bool> get isDark async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
    bool _dark = _sharedPreferences!.getBool('isDark') ?? false;
    if (_dark) {
      darkNotifier.value = true;
    }
    return _dark;
  }

  set setSignedIn(bool value) {
    _sharedPreferences!.setBool('$signedInKey', value);
  }

  FutureOr<bool> get isSignedIn async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
    final _isSignedIn = _sharedPreferences!.getBool('$signedInKey') ?? false;
    return _isSignedIn;
  }

  set setSkipCount(int value) {
    _sharedPreferences!.setInt('$skipCountKey', value);
  }

  FutureOr<int> get skipCount async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }

    final int count =
        _sharedPreferences!.getInt('$skipCountKey') ?? maxSkipCount;
    return count;
  }
}
