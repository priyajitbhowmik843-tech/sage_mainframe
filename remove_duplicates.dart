import 'dart:io';

void main() {
  final file = File('lib/screens/cofounder_dashboard.dart');
  String content = file.readAsStringSync();
  
  // Remove the LAST instances of _getAssigneesForRole and _getAssigneeName
  // which were appended at the bottom
  int idx = content.lastIndexOf('List<Map<String, String>> _getAssigneesForRole');
  if (idx != -1) {
    int endIdx = content.indexOf('void _showAddClientDialog', idx);
    if (endIdx != -1) {
      content = content.replaceRange(idx, endIdx, '');
    }
  }
  
  file.writeAsStringSync(content);
  print('Duplicates removed!');
}
