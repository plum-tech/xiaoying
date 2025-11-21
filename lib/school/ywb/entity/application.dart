import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mimir/session/ywb.dart';
import 'package:mimir/storage/hive/type_id.dart';
import 'package:mimir/school/utils.dart';

part 'application.g.dart';

enum YwbApplicationType {
  complete("Complete_Init"),
  running("Runing_Init"),
  todo("Todolist_Init");

  final String method;

  const YwbApplicationType(this.method);

  String l10nName() => "ywb.type.$name".tr();

  String get messageListUrl =>
      '${YwbSession.base}/unifri-flow/WF/Comm/ProcessRequest.do?DoType=HttpHandler&DoMethod=$method&HttpHandlerName=BP.WF.HttpHandler.WF';
}

final _tsFormat = DateFormat("yyyy-MM-dd hh:mm");

DateTime _parseTimestamp(dynamic ts) {
  return _tsFormat.parse(ts);
}

@JsonSerializable(createToJson: false)
@HiveType(typeId: CacheHiveType.ywbApplication)
@CopyWith(skipFields: true)
class YwbApplication {
  @JsonKey(name: 'WorkID')
  @HiveField(0)
  final int workId;
  @JsonKey(name: 'FK_Flow')
  @HiveField(1)
  final String functionId;
  @JsonKey(name: 'FlowName')
  @HiveField(2)
  final String name;
  @JsonKey(name: 'FlowNote')
  @HiveField(3)
  final String note;
  @JsonKey(name: 'RDT', fromJson: _parseTimestamp)
  @HiveField(4)
  final DateTime startTs;
  @JsonKey(includeFromJson: false, includeToJson: false)
  @HiveField(5)
  final List<YwbApplicationTrack> track;

  const YwbApplication({
    required this.workId,
    required this.functionId,
    required this.name,
    required this.note,
    required this.startTs,
    this.track = const [],
  });

  factory YwbApplication.fromJson(Map<String, dynamic> json) => _$YwbApplicationFromJson(json);

  @override
  String toString() {
    return {
      "workId": workId,
      "functionId": functionId,
      "name": name,
      "note": note,
      "startTs": startTs,
      "track": track,
    }.toString();
  }
}

@JsonSerializable(createToJson: false)
@HiveType(typeId: CacheHiveType.ywbApplicationTrack)
class YwbApplicationTrack {
  @JsonKey(name: "ActionType")
  @HiveField(0)
  final int actionType;
  @JsonKey(name: "ActionTypeText")
  @HiveField(1)
  final String action;
  @JsonKey(name: "EmpFrom")
  @HiveField(2)
  final String senderId;
  @JsonKey(name: "EmpFromT", fromJson: mapChinesePunctuations)
  @HiveField(3)
  final String senderName;
  @JsonKey(name: "EmpTo")
  @HiveField(4)
  final String receiverId;
  @JsonKey(name: "EmpToT", fromJson: mapChinesePunctuations)
  @HiveField(5)
  final String receiverName;
  @JsonKey(name: "Msg", fromJson: mapChinesePunctuations)
  @HiveField(6)
  final String message;
  @JsonKey(name: "RDT", fromJson: _parseTimestamp)
  @HiveField(7)
  final DateTime timestamp;
  @JsonKey(name: "NDFromT", fromJson: mapChinesePunctuations)
  @HiveField(8)
  final String step;

  bool get isActionOk {
    // 发送
    if (actionType == 1) return true;
    // 退回
    if (actionType == 2) return false;
    // 办结
    if (actionType == 8) return true;
    return true;
  }

  const YwbApplicationTrack({
    required this.actionType,
    required this.action,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.message,
    required this.timestamp,
    required this.step,
  });

  factory YwbApplicationTrack.fromJson(Map<String, dynamic> json) => _$YwbApplicationTrackFromJson(json);

  @override
  String toString() {
    return {
      "actionType": actionType,
      "action": action,
      "senderId": senderId,
      "senderName": senderName,
      "receiverId": receiverId,
      "receiverName": receiverName,
      "message": message,
      "timestamp": timestamp,
      "step": step,
    }.toString();
  }
}

typedef MyYwbApplications = ({
  List<YwbApplication> todo,
  List<YwbApplication> running,
  List<YwbApplication> complete,
});

extension MyYwbApplicationsX on MyYwbApplications {
  List<YwbApplication> resolve(YwbApplicationType type) {
    return switch (type) {
      YwbApplicationType.todo => todo,
      YwbApplicationType.running => running,
      YwbApplicationType.complete => complete,
    };
  }
}
