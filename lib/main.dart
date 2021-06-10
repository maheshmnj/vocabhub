import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vocabhub/pages/home.dart';
import 'constants/colors.dart';
import 'constants/constants.dart' show APP_TITLE;

void main() {
  runApp(VocabApp());
}

final ValueNotifier<bool> darkNotifier = ValueNotifier<bool>(false);

class VocabApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: darkNotifier,
        builder: (context, bool isDark, Widget? child) {
          return MaterialApp(
            title: '$APP_TITLE',
            debugShowCheckedModeBanner: !kDebugMode,
            darkTheme: ThemeData.dark(),
            theme: ThemeData(
                primaryColor: Colors.blueAccent,
                iconTheme: IconThemeData(color: primaryBlue)),
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            home: MyHomePage(title: '$APP_TITLE'),
          );
        });
  }
}
