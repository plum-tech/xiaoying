/// 课表显示模式
enum DisplayMode {
  weekly,
  daily;

  static DisplayMode? at(int? index) {
    if (index == null) {
      return null;
    } else if (0 <= index && index < DisplayMode.values.length) {
      return DisplayMode.values[index];
    }
    return null;
  }

  DisplayMode toggle() => DisplayMode.values[(index + 1) & 1];

  String get label => switch (this) {
    DisplayMode.weekly => "周",
    DisplayMode.daily => "日",
  };
}
