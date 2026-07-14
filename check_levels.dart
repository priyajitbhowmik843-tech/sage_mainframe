import 'dart:io';

void main() {
  String content = File('lib/screens/cofounder_dashboard.dart').readAsStringSync();
  int braceCount = 0;
  List<String> lines = content.split('\n');
  for (int i = 0; i < lines.length; i++) {
    String line = lines[i];
    for (int j = 0; j < line.length; j++) {
      if (line[j] == '{') braceCount++;
      if (line[j] == '}') braceCount--;
    }
    if (line.contains('Widget _buildTaskPendingSubTab')) {
      print('Brace count at _buildTaskPendingSubTab: \$braceCount');
    }
    if (line.contains('Widget _buildTaskReviewSubTab')) {
      print('Brace count at _buildTaskReviewSubTab: \$braceCount');
    }
    if (line.contains('List<Map<String, String>> _getAssigneesForRole')) {
      print('Brace count at _getAssigneesForRole: \$braceCount');
    }
  }
}
