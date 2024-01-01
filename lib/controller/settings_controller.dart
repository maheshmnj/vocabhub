import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vocabhub/controller/explore_controller.dart';
import 'package:vocabhub/services/services/settings_service.dart';
import 'package:vocabhub/themes/vocab_theme.dart';

class SettingsController extends ChangeNotifier {
  SettingsService? _settingsService;
  ThemeMode _theme = ThemeMode.light;
  ThemeMode get theme => _theme;
  bool _ratedOnPlayStore = false;
  DateTime _lastRatedDate = DateTime.now();
  bool _isOnboarded = false;
  int _skipCount = 0;
  int maxSkipCount = 3;

  late AutoScroll _autoScroll;

  AutoScroll get autoScroll => _autoScroll;

  bool get hasRatedOnPlaystore => _ratedOnPlayStore;

  bool get isOnboarded => _isOnboarded;

  bool get isDark => _theme == ThemeMode.dark;
  Color _themeSeed = VocabTheme.colorSeeds[1];
  String? version;

  Color get themeSeed => _themeSeed;

  int get skipCount => _skipCount;

  set autoScroll(AutoScroll value) {
    _autoScroll = value;
    notifyListeners();
    _settingsService!.setAutoScroll(_autoScroll);
  }

  set setSkipCount(int value) {
    _skipCount = value;
    notifyListeners();
    _settingsService!.setSkipCount(value);
  }

  Future<AutoScroll> getAutoScroll() async {
    _autoScroll = await _settingsService!.autoScroll;
    return _autoScroll;
  }

  Future<int> getSkipCount() async {
    _skipCount = await _settingsService!.skipCount;
    return _skipCount;
  }

  set lastRatedDate(DateTime value) {
    _lastRatedDate = value;
    notifyListeners();
  }

  DateTime get lastRatedDate => _lastRatedDate;

  Future<bool> getOnBoarded() async {
    _isOnboarded = await _settingsService!.getOnboarded();
    return _isOnboarded;
  }

  /// Returns the last rated sheet shown date
  /// this time does not indicate the user has rated the app
  /// it only indicates the last time the user was shown the rate sheet
  Future<DateTime> getLastRatedShown() async {
    _lastRatedDate = await _settingsService!.getLastRatedShownDate();
    return _lastRatedDate;
  }

  set onBoarded(bool value) {
    _isOnboarded = value;
    notifyListeners();
    _settingsService!.setOnboarded(value);
  }

  set themeSeed(Color value) {
    _themeSeed = value;
    notifyListeners();
    _settingsService!.setThemeSeed(value);
  }

  set ratedOnPlaystore(bool value) {
    _ratedOnPlayStore = value;
    notifyListeners();
    _settingsService!.setRatedOnPlaystore(value);
  }

  bool getRatedOnPlaystore() {
    _ratedOnPlayStore = _settingsService!.getRatedOnPlaystore();
    return _ratedOnPlayStore;
  }

  void setTheme(ThemeMode value) {
    _theme = value;
    notifyListeners();
    _settingsService!.setTheme(value);
  }

  Future<ThemeMode> getTheme() async {
    _theme = await _settingsService!.getTheme();
    return _theme;
  }

  Future<Color> getThemeSeed() async {
    _themeSeed = _settingsService!.getThemeSeed();
    return _themeSeed;
  }

  Future<void> loadSettings() async {
    _settingsService = SettingsService();
    await _settingsService!.initService();
    _theme = await getTheme();
    _themeSeed = await getThemeSeed();
    _ratedOnPlayStore = getRatedOnPlaystore();
    _lastRatedDate = await getLastRatedShown();
    _isOnboarded = await getOnBoarded();
    _skipCount = await getSkipCount();
    _autoScroll = await getAutoScroll();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    notifyListeners();
  }

  Future<void> clearSettings() async {
    onBoarded = true;
  }
}
