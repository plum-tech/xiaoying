import 'package:flutter/widgets.dart';

typedef Task = Future<void> Function();

class TaskBuilder extends StatefulWidget {
  final Task? task;
  final void Function(dynamic error, StackTrace stackTrace)? onError;
  final Widget Function(BuildContext context, Task? task, bool? running) builder;

  const TaskBuilder({
    super.key,
    this.task,
    required this.builder,
    this.onError,
  });

  @override
  State<TaskBuilder> createState() => _TaskBuilderState();
}

class _TaskBuilderState extends State<TaskBuilder> {
  var running = false;

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return widget.builder(
      context,
      task == null || running
          ? null
          : () async {
              setState(() {
                running = true;
              });
              try {
                await task();
              } catch (error, stackTrace) {
                widget.onError?.call(error, stackTrace);
              } finally {
                if (context.mounted) {
                  setState(() {
                    running = false;
                  });
                }
              }
            },
      running,
    );
  }
}
