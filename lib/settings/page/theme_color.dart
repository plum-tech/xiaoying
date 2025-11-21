import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/design/dash.dart';
import 'package:mimir/settings/settings.dart';
import 'package:mimir/utils/color.dart';
import 'package:mimir/utils/save.dart';
import 'package:system_theme/system_theme.dart';
import '../i18n.dart';

class ThemeColorPage extends StatefulWidget {
  const ThemeColorPage({
    super.key,
  });

  @override
  State<ThemeColorPage> createState() => _ThemeColorPageState();
}

class _ThemeColorPageState extends State<ThemeColorPage> {
  late var themeColor = Settings.theme.themeColor ?? getDefaultThemeColor();
  var fromSystem = Settings.theme.themeColorFromSystem;

  @override
  Widget build(BuildContext context) {
    return PromptSaveBeforeQuitScope(
      changed: shouldSave(),
      onSave: onSave,
      child: Scaffold(
        body: CustomScrollView(
          physics: const RangeMaintainingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar.large(
              pinned: true,
              snap: false,
              floating: false,
              title: i18n.themeColor.text(),
              actions: [
                PlatformTextButton(
                  onPressed: onSave,
                  child: i18n.save.text(),
                )
              ],
            ),
            SliverList.list(
              children: [
                buildFromSystemToggle(),
                buildThemeColorTile(),
                ListTile(
                  title: i18n.preview.text(),
                )
              ],
            ),
            SliverToBoxAdapter(
              child: Theme(
                data: context.theme.copyWith(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: fromSystem ? getDefaultThemeColor() : themeColor,
                    brightness: context.theme.brightness,
                  ),
                ),
                child: const ThemeColorPreview(),
              ).padSymmetric(h: 12),
            )
          ],
        ),
      ),
    );
  }

  Color getDefaultThemeColor() {
    return SystemTheme.accentColor.maybeAccent ?? context.colorScheme.primary;
  }

  bool shouldSave() {
    return fromSystem != Settings.theme.themeColorFromSystem ||
        themeColor != (Settings.theme.themeColor ?? getDefaultThemeColor());
  }

  Future<void> selectNewThemeColor() async {
    final newColor = await showColorPickerDialog(
      context,
      themeColor,
      enableOpacity: true,
      enableShadesSelection: true,
      enableTonalPalette: true,
      showColorCode: true,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: true,
        ColorPickerType.primary: false,
        ColorPickerType.accent: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
    );
    setState(() {
      themeColor = newColor;
    });
  }

  Widget buildFromSystemToggle() {
    return SwitchListTile.adaptive(
      title: i18n.fromSystem.text(),
      value: fromSystem,
      onChanged: (value) {
        setState(() {
          fromSystem = value;
        });
      },
    );
  }

  Widget buildThemeColorTile() {
    return ListTile(
      leading: const Icon(Icons.color_lens_outlined),
      enabled: !fromSystem,
      title: i18n.themeColor.text(),
      subtitle: "#${themeColor.hexAlpha}".text(),
      onTap: selectNewThemeColor,
      trailing: Card.filled(
        color: fromSystem ? context.theme.disabledColor : themeColor,
        clipBehavior: Clip.hardEdge,
        child: const SizedBox(
          width: 32,
          height: 32,
        ),
      ),
    );
  }

  Future<void> onSave() async {
    Settings.theme.themeColor = themeColor;
    Settings.theme.themeColorFromSystem = fromSystem;
    final engine = WidgetsFlutterBinding.ensureInitialized();
    engine.performReassemble();
    if (!mounted) return;
    context.pop();
  }
}

class ThemeColorPreview extends StatelessWidget {
  const ThemeColorPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return DashBoxed(
      child: Container(
        child: [
          Card(
            child: _PreviewTile(
              trailing: (v, f) => Checkbox.adaptive(
                value: v,
                onChanged: (v) => f(v != true),
              ),
            ),
          ),
          Card.filled(
              child: _PreviewTile(
            trailing: (v, f) => Switch.adaptive(
              value: v,
              onChanged: f,
            ),
          )),
          const _PreviewButton().padAll(8),
        ].column(caa: CrossAxisAlignment.start),
      ),
    );
  }
}

class _PreviewTile extends StatefulWidget {
  final Widget Function(bool value, ValueChanged<bool> onChanged) trailing;

  const _PreviewTile({
    required this.trailing,
  });

  @override
  State<_PreviewTile> createState() => _PreviewTileState();
}

class _PreviewTileState extends State<_PreviewTile> {
  var selected = true;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.color_lens),
      selected: selected,
      title: i18n.themeColor.text(),
      subtitle: i18n.themeColor.text(),
      trailing: widget.trailing(
        selected,
        (value) {
          setState(() {
            selected = !selected;
          });
        },
      ),
    );
  }
}

class _PreviewButton extends StatefulWidget {
  const _PreviewButton();

  @override
  State<_PreviewButton> createState() => _PreviewButtonState();
}

class _PreviewButtonState extends State<_PreviewButton> {
  @override
  Widget build(BuildContext context) {
    return [
      FilledButton(
        onPressed: () {},
        child: i18n.themeColor.text(),
      ),
      FilledButton.tonal(
        onPressed: () {},
        child: i18n.themeColor.text(),
      ),
      OutlinedButton(
        onPressed: () {},
        child: i18n.themeColor.text(),
      ),
    ].wrap(spacing: 8);
  }
}
