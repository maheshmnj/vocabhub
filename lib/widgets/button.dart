import 'package:flutter/material.dart';

class VocabButton extends StatefulWidget {
  VocabButton(
      {Key? key,
      this.backgroundColor = Colors.white,
      this.foregroundColor = Colors.black,
      required this.onTap,
      required this.label,
      this.height = 55.0,
      this.width,
      this.leading})
      : super(key: key);

  final Function() onTap;

  /// label on the button
  final String label;

  final Widget? leading;

  final Color backgroundColor;

  final Color foregroundColor;

  final double height;

  final double? width;

  @override
  _VocabButtonState createState() => _VocabButtonState();
}

class _VocabButtonState extends State<VocabButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      child: ElevatedButton(
        style: ButtonStyle(
            foregroundColor: MaterialStateColor.resolveWith(
                (states) => widget.foregroundColor),
            backgroundColor: MaterialStateColor.resolveWith(
                (states) => widget.backgroundColor)),
        onPressed: widget.onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.leading ?? SizedBox(),
            SizedBox(width: widget.leading == null ? 0 : 20),
            Text(
              '${widget.label}',
              style: Theme.of(context).textTheme.headline4!.copyWith(
                  fontWeight: FontWeight.bold, color: widget.foregroundColor),
            ),
          ],
        ),
      ),
    );
  }
}
