final RegExp _fixedLineRegex = RegExp(r"(6087\d{4})");
final RegExp _mobileRegex = RegExp(r"(\d{12})");

String linkifyPhoneNumbers(String content) {
  for (final phone in _fixedLineRegex.allMatches(content)) {
    final num = phone.group(0).toString();
    content = content.replaceAll(num, '<a href="tel:021$num">$num</a>');
  }
  for (final mobile in _mobileRegex.allMatches(content)) {
    final num = mobile.group(0).toString();
    content = content.replaceAll(num, '<a href="tel:$num">$num</a>');
  }
  return content;
}
