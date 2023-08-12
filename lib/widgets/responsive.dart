import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vocabhub/utils/size_utils.dart';

class ResponsiveBuilder extends StatefulWidget {
  final WidgetBuilder desktopBuilder;
  final WidgetBuilder mobileBuilder;
  final bool animate;

  const ResponsiveBuilder(
      {Key? key, required this.desktopBuilder, required this.mobileBuilder, this.animate = false})
      : super(key: key);

  @override
  State<ResponsiveBuilder> createState() => _ResponsiveBuilderState();
}

class _ResponsiveBuilderState extends State<ResponsiveBuilder> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 6));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ResponsiveBuilder oldWidget) {
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      child: LayoutBuilder(builder: (context, constraints) {
        SizeUtils.size = Size(constraints.maxWidth, constraints.maxHeight);
        if (!SizeUtils.isMobile) {
          return widget.desktopBuilder(context);
        }
        return Stack(
          children: [
            AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: BackgroundPainter(
                      primaryColor: colorScheme.primary,
                      secondaryColor: colorScheme.secondaryContainer,
                      animation: _animation,
                    ),
                    child: Container(),
                  );
                }),
            BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60), child: Container()),
            widget.mobileBuilder(context),
          ],
        );
      }),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final Animation<double> animation;

  BackgroundPainter(
      {this.primaryColor = Colors.green,
      this.secondaryColor = Colors.white,
      this.animation = const AlwaysStoppedAnimation(0.0)});

  void circleAnimate(Canvas canvas, Size size, {bool blur = true}) {
    final paint2 = Paint();
    Path path2 = Path();
    if (blur) {
      paint2.maskFilter = MaskFilter.blur(BlurStyle.normal, 200);
    }
    final color1 = Colors.blueAccent;
    paint2.style = PaintingStyle.stroke;
    paint2.strokeWidth = 10;
    paint2.color = color1;
    path2.moveTo(size.width * 1.1, size.height / 4);
    path2.quadraticBezierTo(size.width / 2, size.height * 1.0, -100, size.height / 4);
    // canvas.drawPath((path2), paint2);
    final offset = getOffset(path2);
    paint2.style = PaintingStyle.fill;
    canvas.drawCircle(offset, 100, paint2);
    paint2.blendMode = BlendMode.overlay;
  }

  Offset getOffset(Path path) {
    final pms = path.computeMetrics(forceClosed: false).elementAt(0);
    final length = pms.length;
    final offset = pms.getTangentForOffset(length * animation.value)!.position;
    return offset;
  }

  void squareAnimate(Canvas canvas, Size size, {bool blur = true}) {
    final paint1 = Paint();
    Path path1 = Path();
    paint1.color = Colors.redAccent;
    if (blur) {
      paint1.maskFilter = MaskFilter.blur(BlurStyle.normal, 200);
    }
    // square with rounded corners
    paint1.strokeWidth = 10;
    paint1.style = PaintingStyle.stroke;
    path1.moveTo(00, 100);
    path1.quadraticBezierTo(250, 50, 200, 300);
    path1.quadraticBezierTo(150, 500, 300, 400);
    // canvas.drawPath((path1), paint1);
    // get offset from path
    final offset = getOffset(path1);
    paint1.style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: offset,
            width: 200,
            height: 200,
          ),
          Radius.circular(20),
        ),
        paint1);
    paint1.blendMode = BlendMode.overlay;
  }

  void animateEllipse(Canvas canvas, Size size, {bool blur = true}) {
    final paint3 = Paint();
    final path3 = Path();
    paint3.style = PaintingStyle.stroke;
    paint3.strokeWidth = 10;
    path3.moveTo(size.width * 0.6, -100);
    path3.quadraticBezierTo(
        size.width * 0.8, size.height * 0.6, size.width * 1.2, size.height * 0.4);
    paint3.color = primaryColor;
    // canvas.drawPath(path3, paint3);
    final offset = getOffset(path3);
    paint3.style = PaintingStyle.fill;
    if (blur) {
      paint3.maskFilter = MaskFilter.blur(BlurStyle.normal, 40);
    }
    canvas.drawOval(
        Rect.fromCenter(
          center: offset,
          width: 300,
          height: 200,
        ),
        paint3);
    paint3.blendMode = BlendMode.overlay;
  }

  void drawTriangle(Canvas canvas, Size size, {bool blur = true}) {
    final paint4 = Paint();
    paint4.color = secondaryColor;
    final path4 = Path();
    paint4.style = PaintingStyle.stroke;
    if (blur) {
      paint4.maskFilter = MaskFilter.blur(BlurStyle.normal, 40);
    }
    paint4.strokeWidth = 10;
    path4.moveTo(-100.0, size.height * 0.8);
    path4.quadraticBezierTo(100, size.height * 0.7, 300, size.height * 1.2);
    // canvas.drawPath(path4, paint4);
    final offset = getOffset(path4);
    paint4.style = PaintingStyle.fill;
    // draw triangle
    canvas.drawPath(
        Path()
          ..moveTo(offset.dx, offset.dy)
          ..lineTo(offset.dx + 200, offset.dy + 200)
          ..lineTo(offset.dx - 200, offset.dy + 200)
          ..close(),
        paint4);
  }

  @override
  void paint(Canvas canvas, Size size) {
    circleAnimate(canvas, size, blur: true);
    squareAnimate(canvas, size, blur: true);
    animateEllipse(canvas, size, blur: true);
    drawTriangle(canvas, size, blur: true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
