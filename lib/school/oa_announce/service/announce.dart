import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:sit/init.dart';

import 'package:sit/school/entity/school.dart';
import 'package:sit/session/sso.dart';

import '../entity/announce.dart';
import '../entity/page.dart';

final _announceDateTimeFormat = DateFormat('yyyy-MM-dd');
final _departmentSplitRegex = RegExp(r'\s+');
final _dateFormat = DateFormat('yyyy年MM月dd日 hh:mm');

class OaAnnounceService {
  SsoSession get session => Init.ssoSession;

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
    final response = await session.request(
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
        title: titleElement.text.trim(),
        departments: department.trim().split(_departmentSplitRegex),
        dateTime: _announceDateTimeFormat.parse(date),
        catalogId: uri.queryParameters['.pen']!,
        uuid: uri.queryParameters['bulletinId']!,
      );
    }).toList();

    final currentElement = element.find('div', attrs: {'title': '当前页'})!;
    final lastElement = element.find('a', attrs: {'title': '点击跳转到最后页'})!;
    final lastElementHref = Uri.parse(lastElement.attributes['href']!);
    final lastPageIndex = lastElementHref.queryParameters['pageIndex']!;
    return OaAnnounceListPayload(
      items: list,
      currentPage: int.parse(currentElement.text),
      totalPage: int.parse(lastPageIndex),
    );
  }

  Future<OaAnnounceListPayload> queryAnnounceList(int pageIndex, String bulletinCatalogueId) async {
    final response = await session.request(
      // 构造获取文章列表的url
      'https://myportal.sit.edu.cn/detach.portal?pageIndex=$pageIndex&groupid=&action=bulletinsMoreView&.ia=false&pageSize=&.pmn=view&.pen=$bulletinCatalogueId',
      options: Options(
        method: "GET",
      ),
    );
    final soup = BeautifulSoup(response.data);
    return _parseAnnounceListPage(soup.html!);
  }
}
