import 'package:mimir/design/adaptive/editor.dart';

import 'entity/school.dart';

class SchoolInit {
  static void init() {
    EditorEx.registerEnumEditor(Semester.values);
  }
}
