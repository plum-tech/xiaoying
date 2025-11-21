// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credential.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CredentialCWProxy {
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// Credential(...).copyWith(id: 12, name: "My name")
  /// ````
  Credential call({
    String? account,
    String? password,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCredential.copyWith(...)`.
class _$CredentialCWProxyImpl implements _$CredentialCWProxy {
  const _$CredentialCWProxyImpl(this._value);

  final Credential _value;

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored.
  ///
  /// Usage
  /// ```dart
  /// Credential(...).copyWith(id: 12, name: "My name")
  /// ````
  Credential call({
    Object? account = const $CopyWithPlaceholder(),
    Object? password = const $CopyWithPlaceholder(),
  }) {
    return Credential(
      account: account == const $CopyWithPlaceholder() || account == null
          ? _value.account
          // ignore: cast_nullable_to_non_nullable
          : account as String,
      password: password == const $CopyWithPlaceholder() || password == null
          ? _value.password
          // ignore: cast_nullable_to_non_nullable
          : password as String,
    );
  }
}

extension $CredentialCopyWith on Credential {
  /// Returns a callable class that can be used as follows: `instanceOfCredential.copyWith(...)`.
  // ignore: library_private_types_in_public_api
  _$CredentialCWProxy get copyWith => _$CredentialCWProxyImpl(this);
}

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CredentialAdapter extends TypeAdapter<Credential> {
  @override
  final int typeId = 4;

  @override
  Credential read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Credential(
      account: fields[0] as String,
      password: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Credential obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.account)
      ..writeByte(1)
      ..write(obj.password);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CredentialAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
