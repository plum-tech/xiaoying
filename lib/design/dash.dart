import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:rettulf/rettulf.dart';

enum LinePosition { left, top, right, bottom }

class DashDecoration extends Decoration {
  final Set<LinePosition> borders;
  final Color color;
  final List<int> dash;
  final double strokeWidth;

  const DashDecoration.line({
    this.borders = const {},
    required this.color,
    this.dash = const <int>[5, 5],
    this.strokeWidth = 1,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _DashPainter(
      borders: borders,
      color: color,
      dash: dash,
      strokeWidth: strokeWidth,
    );
  }
}

class _DashPainter extends BoxPainter {
  final Set<LinePosition> borders;
  final Color color;
  final List<int> dash;
  final double strokeWidth;

  _DashPainter({
    required this.borders,
    required this.color,
    required this.dash,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    Path outPath = Path();
    for (final border in borders) {
      if (border == LinePosition.left) {
        outPath.moveTo(offset.dx, offset.dy);
        outPath.lineTo(offset.dx, offset.dy + configuration.size!.height);
      } else if (border == LinePosition.top) {
        outPath.moveTo(offset.dx, offset.dy);
        outPath.lineTo(offset.dx + configuration.size!.width, offset.dy);
      } else if (border == LinePosition.right) {
        outPath.moveTo(offset.dx + configuration.size!.width, offset.dy);
        outPath.lineTo(
          offset.dx + configuration.size!.width,
          offset.dy + configuration.size!.height,
        );
      } else {
        outPath.moveTo(offset.dx, offset.dy + configuration.size!.height);
        outPath.lineTo(
          offset.dx + configuration.size!.width,
          offset.dy + configuration.size!.height,
        );
      }
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
          drawPath.addPath(
            me.extractPath(start, to, startWithMoveTo: true),
            Offset.zero,
          );
        }
        start = to;
      }
    }

    canvas.drawPath(
      drawPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
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
  }) : top = enabled,
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
