import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum Weekday {
  monday("周一", "一"),
  tuesday("周二", "二"),
  wednesday("周三", "三"),
  thursday("周四", "四"),
  friday("周五", "五"),
  saturday("周六", "六"),
  sunday("周日", "日");

  final String label;
  final String shortLabel;

  const Weekday(this.label, this.shortLabel);

  int toJson() => index;

  static const calendarOrder = [
    sunday,
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
  ];

  int getIndex({required Weekday firstDay}) {
    return (this - firstDay.index).index;
  }

  static Weekday fromJson(int json) =>
      Weekday.values.elementAtOrNull(json) ?? Weekday.monday;

  static Weekday fromIndex(int index) {
    assert(0 <= index && index < Weekday.values.length);
    return Weekday.values[index % Weekday.values.length];
  }

  static List<Weekday> genSequence(Weekday firstDay) {
    return List.generate(7, (index) => firstDay + index);
  }

  Weekday operator +(int delta) {
    return Weekday.values[(index + delta) % Weekday.values.length];
  }

  Weekday operator -(int delta) {
    return Weekday.values[(index - delta) % Weekday.values.length];
  }

  List<Weekday> genSequenceStartWithThis() => genSequence(this);
}
