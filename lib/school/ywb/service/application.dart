import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mimir/design/animation/progress.dart';
import 'package:mimir/init.dart';

import 'package:mimir/session/ywb.dart';

import '../entity/application.dart';

class YwbApplicationService {
  YwbSession get _session => Init.ywbSession;

  const YwbApplicationService();

  Future<List<YwbApplication>> getApplicationsOf(
    YwbApplicationType type, {
    void Function(double progress)? onProgress,
  }) async {
    final progress = ProgressWatcher(callback: onProgress);
    final response = await _session.request(
      type.messageListUrl,
      data: {
        "myFlow": 1,
        "pageIdx": 1,
        "pageSize": 99,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        method: "POST",
      ),
    );
    progress.value = 0.2;
    final List data = jsonDecode(response.data);
    // filter empty application
    data.retainWhere((e) => e["WorkID"] is int);
    final applications = data.map((e) => YwbApplication.fromJson(e)).toList();
    final per = applications.isEmpty ? 0 : 0.8 / applications.length;
    final res = await Future.wait(applications.map((application) async {
      final track = await _getTrack(workId: application.workId, functionId: application.functionId);
      progress.value += per;
      return application.copyWith(track: track);
    }));
    progress.value = 1;
    return res;
  }

  Future<List<YwbApplicationTrack>> _getTrack({
    required int workId,
    required String functionId,
  }) async {
    // Authentication cookie is even not required!
    final res = await _session.request(
      "${YwbSession.base}/unifri-flow/WF/Comm/ProcessRequest.do?&DoType=HttpHandler&DoMethod=TimeBase_Init&HttpHandlerName=BP.WF.HttpHandler.WF_WorkOpt_OneWork",
      data: {
        "WorkID": workId,
        "FK_Flow": functionId,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        method: "POST",
      ),
    );
    final Map payload = jsonDecode(res.data);
    final List trackRaw = payload["Track"];
    final track = trackRaw.map((e) => YwbApplicationTrack.fromJson(e)).toList();
    return track;
  }
}
