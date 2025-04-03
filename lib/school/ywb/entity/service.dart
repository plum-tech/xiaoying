import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mimir/storage/hive/type_id.dart';
import 'package:mimir/utils/iconfont.dart';

part 'service.g.dart';

@JsonSerializable(createToJson: false)
@HiveType(typeId: CacheHiveType.ywbService)
class YwbService {
  @JsonKey(name: 'appID')
  @HiveField(0)
  final String id;
  @JsonKey(name: 'appName')
  @HiveField(1)
  final String name;
  @JsonKey(name: 'appDescribe')
  @HiveField(2)
  final String summary;
  @JsonKey(name: 'appStatus')
  @HiveField(3)
  final int status;
  @JsonKey(name: 'appCount')
  @HiveField(4)
  final int count;
  @JsonKey(name: 'appIcon')
  @HiveField(5)
  final String iconName;

  IconData get icon => IconFont.query(iconName);

  const YwbService({
    required this.id,
    required this.name,
    required this.summary,
    required this.status,
    required this.count,
    required this.iconName,
  });

  factory YwbService.fromJson(Map<String, dynamic> json) => _$YwbServiceFromJson(json);

  @override
  String toString() {
    return {
      "id": id,
      "name": name,
      "summary": summary,
      "status": status,
      "count": count,
      "iconName": iconName,
    }.toString();
  }
}

@HiveType(typeId: CacheHiveType.ywbServiceDetails)
class YwbServiceDetails {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final List<YwbServiceDetailSection> sections;

  const YwbServiceDetails({
    required this.id,
    required this.sections,
  });

  @override
  String toString() {
    return {
      "id": id,
      "sections": sections,
    }.toString();
  }
}

@JsonSerializable(createToJson: false)
@HiveType(typeId: CacheHiveType.ywbServiceDetailSection)
class YwbServiceDetailSection {
  @JsonKey(name: 'formName')
  @HiveField(0)
  final String section;
  @JsonKey()
  @HiveField(1)
  final String type;
  @JsonKey()
  @HiveField(2)
  final DateTime createTime;
  @JsonKey()
  @HiveField(3)
  final String content;

  const YwbServiceDetailSection({
    required this.type,
    required this.section,
    required this.createTime,
    required this.content,
  });

  factory YwbServiceDetailSection.fromJson(Map<String, dynamic> json) => _$YwbServiceDetailSectionFromJson(json);

  @override
  String toString() {
    return {
      "type": type,
      "section": section,
      "createTime": createTime,
      "content": content,
    }.toString();
  }
}

extension YwbServiceDetailSectionX on YwbServiceDetailSection {
  bool get isEmpty => content.isEmpty;

  bool get isNotEmpty => content.isNotEmpty;
}
