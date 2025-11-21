import 'package:flutter/material.dart';

enum CardVariant {
  elevated,
  filled,
  outlined;
}

extension WidgetCardX on Widget {
  Widget inAnyCard({
    Clip? clip,
    CardVariant type = CardVariant.elevated,
    EdgeInsetsGeometry? margin,
    Color? color,
  }) {
    return switch (type) {
      CardVariant.elevated => Card(
          clipBehavior: clip,
          color: color,
          margin: margin,
          child: this,
        ),
      CardVariant.filled => Card.filled(
          clipBehavior: clip,
          color: color,
          margin: margin,
          child: this,
        ),
      CardVariant.outlined => Card.outlined(
          clipBehavior: clip,
          color: color,
          margin: margin,
          child: this,
        ),
    };
  }
}
