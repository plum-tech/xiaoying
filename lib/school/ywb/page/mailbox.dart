import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:mimir/design/animation/livelist.dart';
import 'package:mimir/design/widgets/common.dart';

import '../entity/message.dart';
import '../init.dart';
import '../widgets/mail.dart';
import '../i18n.dart';

class YwbMailboxPage extends StatefulWidget {
  const YwbMailboxPage({super.key});

  @override
  State<YwbMailboxPage> createState() => _YwbMailboxPageState();
}

class _YwbMailboxPageState extends State<YwbMailboxPage> {
  ApplicationMessagePage? _msgPage;

  @override
  void initState() {
    super.initState();
    YwbInit.messageService.getAllMessage().then((value) {
      if (!mounted) return;
      setState(() {
        _msgPage = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final msg = _msgPage;

    if (msg == null) {
      return const CircularProgressIndicator();
    } else {
      if (msg.msgList.isNotEmpty) {
        return _buildMessageList(context, msg.msgList);
      } else {
        return LeavingBlank(icon: Icons.upcoming_outlined, desc: i18n.mailbox.emptyTip);
      }
    }
  }

  Widget _buildMessageList(BuildContext context, List<ApplicationMessage> list) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final count = constraints.maxWidth ~/ 300;
      return LiveGrid.options(
        itemCount: list.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count,
        ),
        options: commonLiveOptions,
        itemBuilder: (ctx, index, animation) => Mail(msg: list[index]).aliveWith(animation),
      );
    });
  }
}
