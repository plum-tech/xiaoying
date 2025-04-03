import 'announce.dart';

/// 获取到的通知页
class OaAnnounceListPayload {
  final int currentPage;
  final int totalPage;
  final List<OaAnnounceRecord> items;

  const OaAnnounceListPayload({
    required this.currentPage,
    required this.totalPage,
    required this.items,
  });

  @override
  String toString() {
    return {
      "currentPage": currentPage,
      "totalPage": totalPage,
      "items": items,
    }.toString();
  }
}
