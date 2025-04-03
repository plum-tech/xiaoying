// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataPackRaw _$DataPackRawFromJson(Map<String, dynamic> json) => DataPackRaw(
      code: (json['retcode'] as num).toInt(),
      count: (json['retcount'] as num).toInt(),
      transactions:
          (json['retdata'] as List<dynamic>).map((e) => TransactionRaw.fromJson(e as Map<String, dynamic>)).toList(),
      message: json['retmsg'] as String,
    );

TransactionRaw _$TransactionRawFromJson(Map<String, dynamic> json) => TransactionRaw(
      date: json['transdate'] as String,
      time: json['transtime'] as String,
      customerId: (json['custid'] as num).toInt(),
      flag: (json['transflag'] as num).toInt(),
      balanceBeforeTransaction: (json['cardbefbal'] as num).toDouble(),
      balanceAfterTransaction: (json['cardaftbal'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      deviceName: json['devicename'] as String?,
      name: json['transname'] as String,
    );
