import 'package:flutter/material.dart';
import 'package:mimir/design/widget/common.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/utils/error.dart';

import '../entity/result.pg.dart';
import '../init.dart';
import '../widget/pg.dart';
import '../i18n.dart';

class ExamResultPgPage extends StatefulWidget {
  const ExamResultPgPage({super.key});

  @override
  State<ExamResultPgPage> createState() => _ExamResultPgPageState();
}

class _ExamResultPgPageState extends State<ExamResultPgPage> {
  List<ExamResultPg>? resultList;
  bool fetching = false;
  bool isSelecting = false;

  final scrollAreaKey = GlobalKey();
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    if (!mounted) return;
    setState(() {
      resultList = ExamResultInit.pgStorage.getResultList();
      fetching = true;
    });
    try {
      final resultList = await ExamResultInit.pgService.fetchResultList();
      await ExamResultInit.pgStorage.setResultList(resultList);
      if (!mounted) return;
      setState(() {
        this.resultList = resultList;
        fetching = false;
      });
    } catch (error, stackTrace) {
      handleRequestError(error, stackTrace);
      if (!mounted) return;
      setState(() {
        fetching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultList = this.resultList;
    return Scaffold(
      floatingActionButton: !fetching ? null : const CircularProgressIndicator.adaptive(),
      body: CustomScrollView(
        key: scrollAreaKey,
        controller: scrollController,
        slivers: [
          SliverAppBar.medium(
            title: i18n.title.text(),
          ),
          if (resultList != null)
            if (resultList.isEmpty)
              SliverFillRemaining(
                child: LeavingBlank(
                  icon: Icons.inbox_outlined,
                  desc: i18n.noResultsTip,
                ),
              )
            else
              SliverList.builder(
                itemCount: resultList.length,
                itemBuilder: (item, i) => ExamResultPgCard(
                  resultList[i],
                  elevated: false,
                ),
              ),
        ],
      ),
    );
  }
}
