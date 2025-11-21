import 'package:event_bus/event_bus.dart';

import 'entity/pos.dart';

final eventBus = EventBus();

class JumpToPosEvent {
  final TimetablePos where;

  const JumpToPosEvent(this.where);
}
