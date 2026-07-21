import 'dart:io';

void main() {
  String content = File(
    'lib/screens/cofounder_dashboard.dart',
  ).readAsStringSync();
  int braceCount = 0;
  List<String> lines = content.split('\n');
  for (int i = 0; i < lines.length; i++) {
    String line = lines[i];
    for (int j = 0; j < line.length; j++) {
      if (line[j] == '{') braceCount++;
      if (line[j] == '}') braceCount--;
    }
    if (line.contains('Widget _buildTasksTab()')) {
      print(i.toString() + ': ' + braceCount.toString() + ' - ' + line);
    }
    if (line.contains('Widget _buildPersonnelTab()')) {
      print(i.toString() + ': ' + braceCount.toString() + ' - ' + line);
    }
  }
}
