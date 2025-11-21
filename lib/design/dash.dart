import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:rettulf/rettulf.dart';

enum LinePosition {
  left,
  top,
  right,
  bottom;
}

enum Shape {
  line,
  box,
  circle;
}

class DashDecoration extends Decoration {
  final Set<LinePosition> borders;
  final Shape shape;
  final Color color;
  final BorderRadius? borderRadius;
  final List<int> dash;
  final double strokeWidth;

  const DashDecoration.line({
    this.borders = const {},
    required this.color,
    this.dash = const <int>[5, 5],
    this.strokeWidth = 1,
  })  : shape = Shape.line,
        borderRadius = null;

  const DashDecoration.circle({
    required this.color,
    this.dash = const <int>[5, 5],
    this.strokeWidth = 1,
  })  : shape = Shape.circle,
        borders = const {},
        borderRadius = null;

  const DashDecoration.box({
    required this.color,
    this.borderRadius,
    this.dash = const <int>[5, 5],
    this.strokeWidth = 1,
  })  : shape = Shape.box,
        borders = const {};

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _DashPainter(
      shape: shape,
      borders: borders,
      color: color,
      borderRadius: borderRadius,
      dash: dash,
      strokeWidth: strokeWidth,
    );
  }
}

class _DashPainter extends BoxPainter {
  final Set<LinePosition> borders;
  final Shape shape;
  final Color color;
  final BorderRadius borderRadius;
  final List<int> dash;
  final double strokeWidth;

  _DashPainter({
    required this.shape,
    required this.borders,
    required this.color,
    BorderRadius? borderRadius,
    required this.dash,
    required this.strokeWidth,
  }) : borderRadius = borderRadius ?? BorderRadius.circular(0);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    Path outPath = Path();
    if (shape == Shape.line) {
      for (final border in borders) {
        if (border == LinePosition.left) {
          outPath.moveTo(offset.dx, offset.dy);
          outPath.lineTo(offset.dx, offset.dy + configuration.size!.height);
        } else if (border == LinePosition.top) {
          outPath.moveTo(offset.dx, offset.dy);
          outPath.lineTo(offset.dx + configuration.size!.width, offset.dy);
        } else if (border == LinePosition.right) {
          outPath.moveTo(offset.dx + configuration.size!.width, offset.dy);
          outPath.lineTo(offset.dx + configuration.size!.width, offset.dy + configuration.size!.height);
        } else {
          outPath.moveTo(offset.dx, offset.dy + configuration.size!.height);
          outPath.lineTo(offset.dx + configuration.size!.width, offset.dy + configuration.size!.height);
        }
      }
    } else if (shape == Shape.box) {
      RRect rect = RRect.fromLTRBAndCorners(
        offset.dx,
        offset.dy,
        offset.dx + configuration.size!.width,
        offset.dy + configuration.size!.height,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
      );
      outPath.addRRect(rect);
    } else if (shape == Shape.circle) {
      outPath.addOval(Rect.fromLTWH(
        offset.dx,
        offset.dy,
        configuration.size!.width,
        configuration.size!.height,
      ));
    }

    PathMetrics metrics = outPath.computeMetrics(forceClosed: false);
    Path drawPath = Path();

    for (PathMetric me in metrics) {
      double totalLength = me.length;
      int index = -1;

      for (double start = 0; start < totalLength;) {
        double to = start + dash[(++index) % dash.length];
        to = to > totalLength ? totalLength : to;
        bool isEven = index % 2 == 0;
        if (isEven) {
          drawPath.addPath(me.extractPath(start, to, startWithMoveTo: true), Offset.zero);
        }
        start = to;
      }
    }

    canvas.drawPath(
        drawPath,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth);
  }
}

class DashLined extends StatelessWidget {
  final Widget? child;
  final Color? color;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final double strokeWidth;

  const DashLined({
    super.key,
    this.child,
    this.color,
    this.top = false,
    this.bottom = false,
    this.left = false,
    this.right = false,
    this.strokeWidth = 1.0,
  });

  const DashLined.all({
    super.key,
    required bool enabled,
    this.child,
    this.color,
    this.strokeWidth = 1.0,
  })  : top = enabled,
        bottom = enabled,
        left = enabled,
        right = enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: DashDecoration.line(
        color: color ?? context.colorScheme.surfaceTint,
        strokeWidth: strokeWidth,
        borders: {
          if (right) LinePosition.right,
          if (bottom) LinePosition.bottom,
          if (left) LinePosition.left,
          if (top) LinePosition.top,
        },
      ),
      child: child,
    );
  }
}

class DashBoxed extends StatelessWidget {
  final Widget? child;
  final Color? color;
  final BorderRadius borderRadius;
  final double strokeWidth;

  const DashBoxed({
    super.key,
    this.child,
    this.color,
    this.borderRadius = const BorderRadius.all(Radius.circular(12.0)),
    this.strokeWidth = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: DashDecoration.box(
        color: color ?? context.colorScheme.surfaceTint,
        strokeWidth: strokeWidth,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}
