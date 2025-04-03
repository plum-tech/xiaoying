import 'package:json_annotation/json_annotation.dart';

part 'remote.g.dart';

@JsonSerializable(createToJson: false)
class DataPackRaw {
  @JsonKey(name: "retcode")
  final int code;
  @JsonKey(name: "retcount")
  final int count;
  @JsonKey(name: "retdata")
  final List<TransactionRaw> transactions;
  @JsonKey(name: "retmsg")
  final String message;

  const DataPackRaw({
    required this.code,
    required this.count,
    required this.transactions,
    required this.message,
  });

  factory DataPackRaw.fromJson(Map<String, dynamic> json) => _$DataPackRawFromJson(json);
}

@JsonSerializable(createToJson: false)
class TransactionRaw {
  /// transaction name
  /// example: "pos消费", "支付宝充值", "补助领取", "批量销户" or "卡冻结", "余额转移", "下发补助" or "补助撤销"
  @JsonKey(name: "transname")
  final String name;

  /// example: "20221102"
  /// transaction data
  /// format: yyyymmdd
  @JsonKey(name: "transdate")
  final String date;

  /// transaction time
  /// example: "114745"
  /// format: hhmmss
  @JsonKey(name: "transtime")
  final String time;

  /// customer id
  /// example: 11045158
  @JsonKey(name: "custid")
  final int customerId;

  /// transaction flag
  @JsonKey(name: "transflag")
  final int flag;

  /// card before balance
  /// example: 76.5
  @JsonKey(name: "cardbefbal")
  final double balanceBeforeTransaction;

  /// card after balance
  /// example: 70.5
  @JsonKey(name: "cardaftbal")
  final double balanceAfterTransaction;

  /// the amount of this transaction performed
  /// It's absolute.
  /// example: 6
  @JsonKey(name: "amount")
  final double amount;

  /// device name
  /// example: "奉贤一食堂一楼汇多pos4（新）", "多媒体-3-4号楼", "上海应用技术学院"
  @JsonKey(name: "devicename")
  final String? deviceName;

  const TransactionRaw({
    required this.date,
    required this.time,
    required this.customerId,
    required this.flag,
    required this.balanceBeforeTransaction,
    required this.balanceAfterTransaction,
    required this.amount,
    required this.deviceName,
    required this.name,
  });

  factory TransactionRaw.fromJson(Map<String, dynamic> json) => _$TransactionRawFromJson(json);
}
