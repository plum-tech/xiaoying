import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mimir/design/adaptive/multiplatform.dart';
import 'package:mimir/l10n/common.dart';
import 'package:rettulf/rettulf.dart';

import 'foundation.dart';
import 'dialog.dart';

const _i18n = CommonI18n();

typedef EditorBuilder<T> = Widget Function(BuildContext ctx, String? desc, T initial);

class Editor {
  static final Map<Type, EditorBuilder> _customEditor = {};

  static void registerEditor<T>(EditorBuilder<T> builder) {
    _customEditor[T] = (ctx, desc, initial) => builder(ctx, desc, initial);
  }

  static bool isSupport(dynamic test) {
    return test is int ||
        test is String ||
        test is bool ||
        test is DateTime ||
        _customEditor.containsKey(test.runtimeType);
  }

  static Future<T?> showAnyEditor<T>(
    BuildContext context, {
    required T initial,
    String? desc,
    bool readonlyIfNotSupport = true,
  }) async {
    if (initial is int) {
      return await showIntEditor(context, desc: desc, initial: initial) as T?;
    } else if (initial is String) {
      return await showStringEditor(context, desc: desc, initial: initial) as T?;
    } else if (initial is bool) {
      return await showBoolEditor(context, desc: desc, initial: initial) as T?;
    } else if (initial is DateTime) {
      return await showDateTimeEditor(
        context,
        desc: desc,
        initial: initial,
        firstDate: DateTime(0),
        lastDate: DateTime(9999),
      ) as T?;
    } else {
      final customEditorBuilder = _customEditor[initial.runtimeType];
      if (customEditorBuilder != null) {
        return await showAdaptiveDialog<T>(
          context: context,
          builder: (ctx) => customEditorBuilder(ctx, desc, initial),
        );
      } else {
        if (readonlyIfNotSupport) {
          return await showReadonlyEditor(context, desc: desc, initial: initial) as T?;
        } else {
          throw UnsupportedError("Editing $initial is not supported.");
        }
      }
    }
  }

  static Future<DateTime?> showDateTimeEditor(
    BuildContext context, {
    String? desc,
    required DateTime initial,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    final newValue = await showAdaptiveDialog(
      context: context,
      builder: (ctx) => DateTimeEditor(
        initial: initial,
        title: desc,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    );
    if (newValue == null) return null;
    return newValue;
  }

  static Future<bool?> showBoolEditor(
    BuildContext context, {
    String? desc,
    required bool initial,
  }) async {
    final newValue = await showAdaptiveDialog(
      context: context,
      builder: (ctx) => BoolEditor(
        initial: initial,
        desc: desc,
      ),
    );
    if (newValue == null) return null;
    return newValue;
  }

  static Future<String?> showStringEditor(
    BuildContext context, {
    String? desc,
    required String initial,
    bool secure = false,
  }) async {
    final newValue = await showAdaptiveDialog(
      context: context,
      builder: (ctx) => StringEditor(
        initial: initial,
        title: desc,
        secure: secure,
      ),
    );
    if (newValue == null) return null;
    return newValue;
  }

  static Future<void> showReadonlyEditor(
    BuildContext context, {
    String? desc,
    required dynamic initial,
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) => _readonlyEditor(
        ctx,
        (ctx) => SelectableText(initial.toString()),
        title: desc,
      ),
    );
  }

  static Future<int?> showIntEditor(
    BuildContext context, {
    String? desc,
    required int initial,
  }) async {
    final newValue = await showAdaptiveDialog(
      context: context,
      builder: (ctx) => IntEditor(
        initial: initial,
        title: desc,
      ),
    );
    if (newValue == null) return null;
    return newValue;
  }
}

extension EditorEx on Editor {
  static void registerEnumEditor<T>(List<T> values) {
    Editor.registerEditor<T>((ctx, desc, initial) => EnumEditor<T>(
          initial: initial,
          title: desc,
          values: values,
        ));
  }
}

Widget _readonlyEditor(BuildContext ctx, WidgetBuilder make, {String? title}) {
  return $Dialog$(
      title: title,
      primary: $Action$(
          text: _i18n.close,
          onPressed: () {
            ctx.navigator.pop(false);
          }),
      desc: (ctx) => make(ctx));
}

class EnumEditor<T> extends StatefulWidget {
  final T initial;
  final List<T> values;
  final String? title;

  const EnumEditor({
    super.key,
    required this.initial,
    this.title,
    required this.values,
  });

  @override
  State<EnumEditor<T>> createState() => _EnumEditorState<T>();
}

class _EnumEditorState<T> extends State<EnumEditor<T>> {
  late T current = widget.initial;
  late final int initialIndex = max(widget.values.indexOf(widget.initial), 0);

  @override
  Widget build(BuildContext context) {
    return $Dialog$(
      title: widget.title,
      primary: $Action$(
        text: _i18n.submit,
        isDefault: true,
        onPressed: () {
          context.navigator.pop(current);
        },
      ),
      secondary: $Action$(
        text: _i18n.cancel,
        onPressed: () {
          context.navigator.pop();
        },
      ),
      desc: (ctx) => PlatformTextButton(
        child: current.toString().text(),
        onPressed: () async {
          final controller = FixedExtentScrollController(initialItem: initialIndex);
          controller.addListener(() {
            final selected = widget.values[controller.selectedItem];
            if (selected != current) {
              setState(() {
                current = selected;
              });
            }
          });
          await ctx.showPicker(
            count: widget.values.length,
            controller: controller,
            make: (ctx, index) => widget.values[index].toString().text(),
          );
          controller.dispose();
        },
      ),
    );
  }
}

class DateTimeEditor extends StatefulWidget {
  final DateTime initial;
  final String? title;
  final DateTime firstDate;
  final DateTime lastDate;

  const DateTimeEditor({
    super.key,
    required this.initial,
    this.title,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<DateTimeEditor> createState() => _DateTimeEditorState();
}

class _DateTimeEditorState extends State<DateTimeEditor> {
  late DateTime current = widget.initial;

  @override
  Widget build(BuildContext context) {
    return $Dialog$(
      title: widget.title,
      primary: $Action$(
          text: _i18n.submit,
          isDefault: true,
          onPressed: () {
            context.navigator.pop(current);
          }),
      secondary: $Action$(
          text: _i18n.cancel,
          onPressed: () {
            context.navigator.pop();
          }),
      desc: (ctx) => PlatformTextButton(
        child: current.toString().text(),
        onPressed: () async {
          final newDate = await showDatePicker(
            context: context,
            initialDate: widget.initial,
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
          );
          if (newDate != null) {
            setState(() {
              current = newDate;
            });
          }
        },
      ),
    );
  }
}

class IntEditor extends StatefulWidget {
  final int initial;
  final String? title;

  const IntEditor({super.key, required this.initial, this.title});

  @override
  State<IntEditor> createState() => _IntEditorState();
}

class _IntEditorState extends State<IntEditor> {
  late TextEditingController controller;
  late int value = widget.initial;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initial.toString());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return $Dialog$(
        title: widget.title,
        primary: $Action$(
            text: _i18n.submit,
            isDefault: true,
            onPressed: () {
              context.navigator.pop(value);
            }),
        secondary: $Action$(
            text: _i18n.cancel,
            onPressed: () {
              context.navigator.pop();
            }),
        desc: (ctx) => buildBody(ctx));
  }

  Widget buildBody(BuildContext ctx) {
    return Row(
      children: [
        PlatformTextButton(
          child: Icon(ctx.icons.remove),
          onPressed: () {
            setState(() {
              value--;
              controller.text = value.toString();
            });
          },
        ),
        $TextField$(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'\d')),
          ],
          onChanged: (v) {
            final newV = int.tryParse(v);
            if (newV != null) {
              setState(() {
                value = newV;
              });
            }
          },
        ).sized(w: 100),
        PlatformTextButton(
          child: Icon(ctx.icons.add),
          onPressed: () {
            setState(() {
              value++;
              controller.text = value.toString();
            });
          },
        ),
      ],
    );
  }
}

class BoolEditor extends StatefulWidget {
  final bool initial;
  final String? desc;

  const BoolEditor({
    super.key,
    required this.initial,
    this.desc,
  });

  @override
  State<BoolEditor> createState() => _BoolEditorState();
}

class _BoolEditorState extends State<BoolEditor> {
  late bool value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return $Dialog$(
      primary: $Action$(
        text: _i18n.submit,
        isDefault: true,
        onPressed: () {
          context.navigator.pop(value);
        },
      ),
      secondary: $Action$(
        text: _i18n.cancel,
        onPressed: () {
          context.navigator.pop();
        },
      ),
      desc: (ctx) => Material(
        color: Colors.transparent,
        child: SwitchListTile.adaptive(
          title: (widget.desc ?? "").text(style: context.textTheme.bodySmall),
          value: value,
          onChanged: (newValue) {
            setState(() {
              value = newValue;
            });
          },
        ),
      ),
    );
  }
}

class StringEditor extends StatefulWidget {
  final String initial;
  final String? title;
  final bool secure;

  const StringEditor({
    super.key,
    required this.initial,
    this.title,
    this.secure = false,
  });

  @override
  State<StringEditor> createState() => _StringEditorState();
}

class _StringEditorState extends State<StringEditor> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lines = context.isPortrait ? widget.initial.length ~/ 30 + 1 : widget.initial.length ~/ 100 + 1;
    return $Dialog$(
      title: widget.title,
      primary: $Action$(
        text: _i18n.submit,
        isDefault: true,
        onPressed: () {
          context.navigator.pop(controller.text);
        },
      ),
      secondary: $Action$(
        text: _i18n.cancel,
        onPressed: () {
          context.navigator.pop();
        },
      ),
      desc: (ctx) => PlatformTextField(
        maxLines: lines,
        controller: controller,
        obscureText: widget.secure,
      ),
    );
  }
}

class StringsEditor<T> extends StatefulWidget {
  final List<({String name, String initial})> fields;
  final String? title;
  final T Function(List<String> values) ctor;

  const StringsEditor({
    super.key,
    required this.fields,
    required this.title,
    required this.ctor,
  });

  @override
  State<StringsEditor> createState() => _StringsEditorState();
}

class _StringsEditorState extends State<StringsEditor> {
  late List<({String name, TextEditingController $value})> $values;

  late TextEditingController $password;

  @override
  void initState() {
    super.initState();
    $values = widget.fields.map((e) => (name: e.name, $value: TextEditingController(text: e.initial))).toList();
  }

  @override
  void dispose() {
    for (final (name: _, :$value) in $values) {
      $value.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return $Dialog$(
      title: widget.title,
      desc: (ctx) => $values.map((e) => buildField(e.name, e.$value)).toList().column(mas: MainAxisSize.min),
      primary: $Action$(
          text: _i18n.submit,
          onPressed: () {
            context.navigator.pop(widget.ctor($values.map((e) => e.$value.text).toList()));
          }),
      secondary: $Action$(
          text: _i18n.cancel,
          onPressed: () {
            context.navigator.pop();
          }),
    );
  }

  Widget buildField(String fieldName, TextEditingController controller) {
    return $TextField$(
      controller: controller,
      textInputAction: TextInputAction.next,
      labelText: fieldName,
    ).padV(1);
  }
}
