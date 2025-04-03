// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'palette.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TimetablePaletteCWProxy {
  TimetablePalette uuid(String uuid);

  TimetablePalette name(String name);

  TimetablePalette author(String author);

  TimetablePalette colors(List<DualColor> colors);

  TimetablePalette lastModified(DateTime lastModified);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TimetablePalette(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TimetablePalette(...).copyWith(id: 12, name: "My name")
  /// ````
  TimetablePalette call({
    String? uuid,
    String? name,
    String? author,
    List<DualColor>? colors,
    DateTime? lastModified,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTimetablePalette.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfTimetablePalette.copyWith.fieldName(...)`
class _$TimetablePaletteCWProxyImpl implements _$TimetablePaletteCWProxy {
  const _$TimetablePaletteCWProxyImpl(this._value);

  final TimetablePalette _value;

  @override
  TimetablePalette uuid(String uuid) => this(uuid: uuid);

  @override
  TimetablePalette name(String name) => this(name: name);

  @override
  TimetablePalette author(String author) => this(author: author);

  @override
  TimetablePalette colors(List<DualColor> colors) => this(colors: colors);

  @override
  TimetablePalette lastModified(DateTime lastModified) => this(lastModified: lastModified);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `TimetablePalette(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// TimetablePalette(...).copyWith(id: 12, name: "My name")
  /// ````
  TimetablePalette call({
    Object? uuid = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? author = const $CopyWithPlaceholder(),
    Object? colors = const $CopyWithPlaceholder(),
    Object? lastModified = const $CopyWithPlaceholder(),
  }) {
    return TimetablePalette(
      uuid: uuid == const $CopyWithPlaceholder() || uuid == null
          ? _value.uuid
          // ignore: cast_nullable_to_non_nullable
          : uuid as String,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      author: author == const $CopyWithPlaceholder() || author == null
          ? _value.author
          // ignore: cast_nullable_to_non_nullable
          : author as String,
      colors: colors == const $CopyWithPlaceholder() || colors == null
          ? _value.colors
          // ignore: cast_nullable_to_non_nullable
          : colors as List<DualColor>,
      lastModified: lastModified == const $CopyWithPlaceholder() || lastModified == null
          ? _value.lastModified
          // ignore: cast_nullable_to_non_nullable
          : lastModified as DateTime,
    );
  }
}

extension $TimetablePaletteCopyWith on TimetablePalette {
  /// Returns a callable class that can be used as follows: `instanceOfTimetablePalette.copyWith(...)` or like so:`instanceOfTimetablePalette.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TimetablePaletteCWProxy get copyWith => _$TimetablePaletteCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimetablePalette _$TimetablePaletteFromJson(Map<String, dynamic> json) => TimetablePalette(
      uuid: json['uuid'] as String? ?? _kUUid(),
      name: json['name'] as String,
      author: json['author'] as String,
      colors: (json['colors'] as List<dynamic>)
          .map((e) => const _DualColorMigratedFromColor2ModeConverter().fromJson(e as Map))
          .toList(),
      lastModified: json['lastModified'] == null ? _kLastModified() : DateTime.parse(json['lastModified'] as String),
    );

Map<String, dynamic> _$TimetablePaletteToJson(TimetablePalette instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'name': instance.name,
      'author': instance.author,
      'colors': instance.colors.map(const _DualColorMigratedFromColor2ModeConverter().toJson).toList(),
      'lastModified': instance.lastModified.toIso8601String(),
    };
