// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cell_style.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CourseCellStyleCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// CourseCellStyle(...).copyWith(id: 12, name: "My name")
  /// ````
  CourseCellStyle call({
    bool? showTeachers,
    bool? grayOutTakenLessons,
    bool? harmonizeWithThemeColor,
    double? alpha,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCourseCellStyle.copyWith(...)`.
class _$CourseCellStyleCWProxyImpl implements _$CourseCellStyleCWProxy {
  const _$CourseCellStyleCWProxyImpl(this._value);

  final CourseCellStyle _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// CourseCellStyle(...).copyWith(id: 12, name: "My name")
  /// ````
  CourseCellStyle call({
    Object? showTeachers = const $CopyWithPlaceholder(),
    Object? grayOutTakenLessons = const $CopyWithPlaceholder(),
    Object? harmonizeWithThemeColor = const $CopyWithPlaceholder(),
    Object? alpha = const $CopyWithPlaceholder(),
  }) {
    return CourseCellStyle(
      showTeachers: showTeachers == const $CopyWithPlaceholder() || showTeachers == null
          ? _value.showTeachers
          // ignore: cast_nullable_to_non_nullable
          : showTeachers as bool,
      grayOutTakenLessons: grayOutTakenLessons == const $CopyWithPlaceholder() || grayOutTakenLessons == null
          ? _value.grayOutTakenLessons
          // ignore: cast_nullable_to_non_nullable
          : grayOutTakenLessons as bool,
      harmonizeWithThemeColor:
          harmonizeWithThemeColor == const $CopyWithPlaceholder() || harmonizeWithThemeColor == null
              ? _value.harmonizeWithThemeColor
              // ignore: cast_nullable_to_non_nullable
              : harmonizeWithThemeColor as bool,
      alpha: alpha == const $CopyWithPlaceholder() || alpha == null
          ? _value.alpha
          // ignore: cast_nullable_to_non_nullable
          : alpha as double,
    );
  }
}

extension $CourseCellStyleCopyWith on CourseCellStyle {
  /// Returns a callable class that can be used as follows: `instanceOfCourseCellStyle.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$CourseCellStyleCWProxy get copyWith => _$CourseCellStyleCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseCellStyle _$CourseCellStyleFromJson(Map<String, dynamic> json) => CourseCellStyle(
      showTeachers: json['showTeachers'] as bool? ?? true,
      grayOutTakenLessons: json['grayOutTakenLessons'] as bool? ?? false,
      harmonizeWithThemeColor: json['harmonizeWithThemeColor'] as bool? ?? true,
      alpha: (json['alpha'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$CourseCellStyleToJson(CourseCellStyle instance) => <String, dynamic>{
      'showTeachers': instance.showTeachers,
      'grayOutTakenLessons': instance.grayOutTakenLessons,
      'harmonizeWithThemeColor': instance.harmonizeWithThemeColor,
      'alpha': instance.alpha,
    };
