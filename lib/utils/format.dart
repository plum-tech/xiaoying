import 'package:collection/collection.dart';

String formatWithoutTrailingZeros(
  double amount, {
  int fractionDigits = 2,
}) {
  if (amount == 0) return "0";
  final number = amount.toStringAsFixed(fractionDigits);
  if (number.contains('.')) {
    int index = number.length - 1;
    while (index >= 0 && number[index] == '0') {
      index--;
      if (index >= 0 && number[index] == '.') {
        index--;
        break;
      }
    }
    return number.substring(0, index + 1);
  }
  return number;
}

final _trailingIntRe = RegExp(r"(.*\s+)(\d+)$");

String getDuplicateFileName(String origin, {List<String>? all}) {
  assert(all == null || all.contains(origin));
  final (name: originName, number: originNumber) = _extractTrailingNumber(origin);
  if (originNumber != null && (all == null || all.length <= 1)) {
    return "$originName${originNumber + 1}";
  }
  if (all == null || all.length <= 1) return "$origin 2";
  final numbers = <int>[];
  for (final file in all) {
    final (:name, :number) = _extractTrailingNumber(file);
    if (number == null) continue;
    if (file == origin || (originNumber == null && name == "$originName ") || name == originName) {
      numbers.add(number);
    }
  }
  final maxNumber = numbers.maxOrNull;
  if (maxNumber == null) {
    return "$origin 2";
  }
  if (originNumber == null) {
    return "$originName ${maxNumber + 1}";
  } else {
    return "$originName${maxNumber + 1}";
  }
}

({String name, int? number}) _extractTrailingNumber(String s) {
  final matched = _trailingIntRe.firstMatch(s);
  if (matched == null) return (name: s, number: null);
  final prefix = matched.group(1);
  final numberRaw = matched.group(2);
  if (prefix == null || numberRaw == null) return (name: "", number: null);
  final number = int.tryParse(numberRaw, radix: 10);
  if (number == null) return (name: prefix, number: null);
  return (name: prefix, number: number);
}

String allocValidFileName(String name, {List<String>? all}) {
  if (all == null || all.isEmpty) return name;
  if (!all.contains(name)) return name;
  return getDuplicateFileName(name, all: all);
}
