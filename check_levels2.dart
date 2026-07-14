import 'dart:io';

void main() {
  String content = File('lib/screens/cofounder_dashboard.dart').readAsStringSync();
  int braceCount = 0;
  List<String> lines = content.split('\n');
  for (int i = 0; i < lines.length; i++) {
    String line = lines[i];
    // extremely crude but enough for this
    for (int j = 0; j < line.length; j++) {
      if (line[j] == '{') braceCount++;
      if (line[j] == '}') braceCount--;
    }
    if (line.contains('_buildTaskPendingSubTab') || line.contains('_buildTaskReviewSubTab') || line.contains('List<Map<String, String>> _getAssigneesForRole')) {
      print('\$i: \$braceCount - \$line');
    }
  }
}
