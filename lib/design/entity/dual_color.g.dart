// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dual_color.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ColorEntryCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// ColorEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  ColorEntry call({
    Color? color,
    bool? inverseText,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfColorEntry.copyWith(...)`.
class _$ColorEntryCWProxyImpl implements _$ColorEntryCWProxy {
  const _$ColorEntryCWProxyImpl(this._value);

  final ColorEntry _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// ColorEntry(...).copyWith(id: 12, name: "My name")
  /// ````
  ColorEntry call({
    Object? color = const $CopyWithPlaceholder(),
    Object? inverseText = const $CopyWithPlaceholder(),
  }) {
    return ColorEntry(
      color == const $CopyWithPlaceholder() || color == null
          ? _value.color
          // ignore: cast_nullable_to_non_nullable
          : color as Color,
      inverseText: inverseText == const $CopyWithPlaceholder() || inverseText == null
          ? _value.inverseText
          // ignore: cast_nullable_to_non_nullable
          : inverseText as bool,
    );
  }
}

extension $ColorEntryCopyWith on ColorEntry {
  /// Returns a callable class that can be used as follows: `instanceOfColorEntry.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$ColorEntryCWProxy get copyWith => _$ColorEntryCWProxyImpl(this);
}

abstract class _$DualColorCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// DualColor(...).copyWith(id: 12, name: "My name")
  /// ````
  DualColor call({
    ColorEntry? light,
    ColorEntry? dark,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDualColor.copyWith(...)`.
class _$DualColorCWProxyImpl implements _$DualColorCWProxy {
  const _$DualColorCWProxyImpl(this._value);

  final DualColor _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// DualColor(...).copyWith(id: 12, name: "My name")
  /// ````
  DualColor call({
    Object? light = const $CopyWithPlaceholder(),
    Object? dark = const $CopyWithPlaceholder(),
  }) {
    return DualColor(
      light: light == const $CopyWithPlaceholder() || light == null
          ? _value.light
          // ignore: cast_nullable_to_non_nullable
          : light as ColorEntry,
      dark: dark == const $CopyWithPlaceholder() || dark == null
          ? _value.dark
          // ignore: cast_nullable_to_non_nullable
          : dark as ColorEntry,
    );
  }
}

extension $DualColorCopyWith on DualColor {
  /// Returns a callable class that can be used as follows: `instanceOfDualColor.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$DualColorCWProxy get copyWith => _$DualColorCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ColorEntry _$ColorEntryFromJson(Map<String, dynamic> json) => ColorEntry(
      _colorFromJson((json['color'] as num).toInt()),
      inverseText: json['inverseText'] as bool? ?? false,
    );

Map<String, dynamic> _$ColorEntryToJson(ColorEntry instance) => <String, dynamic>{
      'color': _colorToJson(instance.color),
      'inverseText': instance.inverseText,
    };

DualColor _$DualColorFromJson(Map<String, dynamic> json) => DualColor(
      light: ColorEntry.fromJson(json['light'] as Map<String, dynamic>),
      dark: ColorEntry.fromJson(json['dark'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DualColorToJson(DualColor instance) => <String, dynamic>{
      'light': instance.light,
      'dark': instance.dark,
    };
