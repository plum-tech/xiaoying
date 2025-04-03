import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';

class ModalImageViewer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Object? hereTag;

  const ModalImageViewer({
    super.key,
    required this.child,
    this.backgroundColor = Colors.black,
    this.hereTag,
  });

  @override
  Widget build(BuildContext context) {
    final tag = hereTag ?? UniqueKey();
    return Hero(
      tag: tag,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (BuildContext context, _, __) {
                return FullScreenViewer(
                  heroTag: tag,
                  backgroundColor: backgroundColor,
                  child: child,
                );
              },
            ),
          );
        },
        child: child,
      ),
    );
  }
}

class FullScreenViewer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Object heroTag;

  const FullScreenViewer({
    super.key,
    required this.child,
    required this.heroTag,
    this.backgroundColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: GestureDetector(
                onDoubleTap: () {
                  context.pop();
                },
                child: InteractiveViewer(
                  maxScale: 5,
                  minScale: 0.5,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  child: child,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: PlatformIconButton(
                icon: Icon(
                  context.icons.clear,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ).padAll(16),
            ).safeArea(),
          ],
        ),
      ),
    );
  }
}
