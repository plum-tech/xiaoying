import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

extension TrX on String {
  List<InlineSpan> trSpan({
    BuildContext? context,
    required Map<String, InlineSpan> args,
  }) {
    final translated = this.tr(
      namedArgs: args.map((k, v) => MapEntry(k, "{$k}")),
    );
    return replaceWidget(raw: translated, args: args);
  }
}

List<InlineSpan> replaceWidget({
  required String raw,
  required Map<String, InlineSpan> args,
}) {
  List<InlineSpan> spans = [];
  RegExp regExp = RegExp(r'{(.*?)}');
  Iterable<Match> matches = regExp.allMatches(raw);
  int currentIndex = 0;

  for (Match match in matches) {
    spans.add(TextSpan(text: raw.substring(currentIndex, match.start)));
    final key = match.group(1);
    if (key == null) {
      spans.add(const TextSpan(text: "?"));
    } else {
      final replaced = args[key];
      if (replaced == null) {
        spans.add(TextSpan(text: key));
      } else {
        spans.add(replaced);
      }
    }
    currentIndex = match.end;
  }

  if (currentIndex < raw.length) {
    spans.add(TextSpan(text: raw.substring(currentIndex)));
  }
  return spans;
}
