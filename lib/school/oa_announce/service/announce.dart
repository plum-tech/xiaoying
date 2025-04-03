import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:mimir/init.dart';
import 'package:mimir/school/utils.dart';
import 'package:mimir/session/sso.dart';

import '../entity/announce.dart';
import '../entity/page.dart';

final _announceDateTimeFormat = DateFormat('yyyy-MM-dd');
final _departmentSplitRegex = RegExp(r'\s+');
final _dateFormat = DateFormat('yyyy年MM月dd日 hh:mm');

class OaAnnounceService {
  SsoSession get _session => Init.ssoSession;

  const OaAnnounceService();

  List<OaAnnounceAttachment> _parseAttachment(Bs4Element element) {
    return element.find('#containerFrame > table')!.findAll('a').map((e) {
      return OaAnnounceAttachment(
        name: e.text.trim(),
        url: 'https://myportal.sit.edu.cn/${e.attributes['href']!}',
      );
    }).toList();
  }

  OaAnnounceDetails _parseAnnounceDetails(Bs4Element item) {
    String metaHtml = item.find('div', class_: 'bulletin-info')?.innerHtml ?? '';
    // 删除注释
    metaHtml = metaHtml.replaceAll('<!--', '').replaceAll(r'-->', '');
    String meta = BeautifulSoup(metaHtml).text;

    final metaList = meta.split('|').map((e) => e.trim()).toList();
    final title = item.find('div', class_: 'bulletin-title')?.text.trim() ?? '';
    final author = metaList[2].substring(3);
    final department = metaList[1].substring(5);
    return OaAnnounceDetails(
      title: mapChinesePunctuations(title),
      content: item.find('div', class_: 'bulletin-content')?.innerHtml ?? '',
      attachments: _parseAttachment(item),
      dateTime: _dateFormat.parse(metaList[0].substring(5)),
      department: mapChinesePunctuations(department),
      author: mapChinesePunctuations(author),
      readNumber: int.parse(metaList[3].substring(5)),
    );
  }

  static String getAnnounceUrl(String catalogueId, String uuid) {
    return 'https://myportal.sit.edu.cn/detach.portal?action=bulletinBrowser&.ia=false&.pmn=view&.pen=$catalogueId&bulletinId=$uuid';
  }

  Future<OaAnnounceDetails> fetchAnnounceDetails(String catalogId, String uuid) async {
    final response = await _session.request(
      getAnnounceUrl(catalogId, uuid),
      options: Options(
        method: "GET",
      ),
    );
    final soup = BeautifulSoup(response.data);
    return _parseAnnounceDetails(soup.html!);
  }

  static OaAnnounceListPayload _parseAnnounceListPage(Bs4Element element) {
    final list = element.findAll('li').map((e) {
      final departmentAndDate = e.find('span', class_: 'rss-time')!.text.trim();
      final departmentAndDateLen = departmentAndDate.length;
      final department = departmentAndDate.substring(0, departmentAndDateLen - 8);
      final date = '20${departmentAndDate.substring(departmentAndDateLen - 8, departmentAndDateLen)}';

      final titleElement = e.find('a', class_: 'rss-title')!;
      final uri = Uri.parse(titleElement.attributes['href']!);

      return OaAnnounceRecord(
        title: mapChinesePunctuations(titleElement.text.trim()),
        departments: department.trim().split(_departmentSplitRegex).map(mapChinesePunctuations).toList(),
        dateTime: _announceDateTimeFormat.parse(date),
        catalogId: uri.queryParameters['.pen']!,
        uuid: uri.queryParameters['bulletinId']!,
      );
    }).toList();

    ({int currentPage, int totalPage})? parsePage() {
      final currentRaw = element.find('div', attrs: {'title': '当前页'})?.text;
      if (currentRaw == null) return null;
      final lastElement = element.find('a', attrs: {'title': '点击跳转到最后页'});
      if (lastElement == null) return null;
      final lastElementHref = Uri.parse(lastElement.attributes['href']!);
      final lastPageIndex = lastElementHref.queryParameters['pageIndex']!;
      return (currentPage: int.parse(currentRaw), totalPage: int.parse(lastPageIndex));
    }

    final page = parsePage();

    return OaAnnounceListPayload(
      items: list,
      currentPage: page?.currentPage ?? 1,
      totalPage: page?.totalPage ?? 1,
    );
  }

  Future<OaAnnounceListPayload> getAnnounceList(OaAnnounceCat cat, int pageIndex) async {
    final response = await _session.request(
        'https://myportal.sit.edu.cn/detach.portal?pageIndex=$pageIndex&groupid=&action=bulletinsMoreView&.ia=false&pageSize=&.pmn=view&.pen=${cat.internalId}');
    final html = BeautifulSoup(response.data);
    return _parseAnnounceListPage(html.html!);
  }
}
