import 'package:flutter/material.dart';
import 'package:vocabhub/utils/utils.dart';

/// Creates a [ThemeSelector] widget.
/// The [value] and [onThemeChanged] arguments must not be null.
/// The [value] must be one of the following colors:
/// [Colors.red], [Colors.green], [Colors.blue], [Colors.yellow], [Colors.purple]
class ThemeSelector extends StatefulWidget {
  ///  The color value for the theme.
  final Color value;

  /// The callback that is called when the theme is changed.
  final Function(Color color) onThemeChanged;

  final List<Color> colors;

  ThemeSelector({
    Key? key,
    required this.value,
    required this.onThemeChanged,
    this.colors = const [Colors.pink, Colors.green, Colors.blue, Colors.yellow, Colors.purple],
  }) : super(key: key);

  @override
  State<ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<ThemeSelector> {
  Widget circle(Color color, bool isSelected) {
    return AnimatedContainer(
        height: 30,
        width: 30,
        duration: const Duration(milliseconds: 300),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              )
            : const SizedBox.shrink());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Center(
        child: ListView(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          children: [
            for (var color in widget.colors)
              GestureDetector(
                onTap: () {
                  if (widget.value.value != color.value) {
                    widget.onThemeChanged(color);
                  }
                },
                child: Padding(
                    padding: 12.0.horizontalPadding,
                    child: circle(color, widget.value.value == color.value)),
              ),
          ],
        ),
      ),
    );
  }
}
