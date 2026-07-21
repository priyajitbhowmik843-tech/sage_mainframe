import 'dart:io';

void replacePersonnelTab(String filePath) {
  var file = File(filePath);
  var content = file.readAsStringSync();

  var payloadFile = File('new_personnel_payload.txt');
  var payload = payloadFile.readAsStringSync();

  int startIdx = content.indexOf('Widget _buildPersonnelTab() {');
  int endIdx = filePath.contains('ceo')
      ? content.indexOf("String _taskSubTab = 'CALENDAR';")
      : content.indexOf('Widget _buildTasksTab() {');

  if (startIdx == -1 || endIdx == -1) {
    print('Could not find boundaries in $filePath');
    return;
  }

  String before = content.substring(0, startIdx);
  String after = content.substring(endIdx);

  String newContent = before + payload + '\n\n  ' + after;
  file.writeAsStringSync(newContent);
  print('Updated $filePath successfully.');
}

void main() {
  replacePersonnelTab('lib/screens/ceo_dashboard.dart');
  replacePersonnelTab('lib/screens/cofounder_dashboard.dart');
}
