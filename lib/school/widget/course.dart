import 'package:flutter/widgets.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/school/entity/icon.dart';

class CourseIcon extends StatelessWidget {
  final String courseName;
  final double? size;
  final bool enabled;
  static const kDefaultSize = 45.0;

  const CourseIcon({
    super.key,
    required this.courseName,
    this.enabled = true,
    this.size = kDefaultSize,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      CourseIcons.iconPathOf(courseName: courseName),
      width: size,
      height: size,
      color: enabled ? null : context.theme.disabledColor,
    ).sized(w: kDefaultSize, h: kDefaultSize);
  }
}
