// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'style.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TimetableStyleDataCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// TimetableStyleData(...).copyWith(id: 12, name: "My name")
  /// ````
  TimetableStyleData call({
    TimetablePalette? platte,
    CourseCellStyle? cellStyle,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfTimetableStyleData.copyWith(...)`.
class _$TimetableStyleDataCWProxyImpl implements _$TimetableStyleDataCWProxy {
  const _$TimetableStyleDataCWProxyImpl(this._value);

  final TimetableStyleData _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// TimetableStyleData(...).copyWith(id: 12, name: "My name")
  /// ````
  TimetableStyleData call({
    Object? platte = const $CopyWithPlaceholder(),
    Object? cellStyle = const $CopyWithPlaceholder(),
  }) {
    return TimetableStyleData(
      platte: platte == const $CopyWithPlaceholder() || platte == null
          ? _value.platte
          // ignore: cast_nullable_to_non_nullable
          : platte as TimetablePalette,
      cellStyle: cellStyle == const $CopyWithPlaceholder() || cellStyle == null
          ? _value.cellStyle
          // ignore: cast_nullable_to_non_nullable
          : cellStyle as CourseCellStyle,
    );
  }
}

extension $TimetableStyleDataCopyWith on TimetableStyleData {
  /// Returns a callable class that can be used as follows: `instanceOfTimetableStyleData.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$TimetableStyleDataCWProxy get copyWith => _$TimetableStyleDataCWProxyImpl(this);
}
