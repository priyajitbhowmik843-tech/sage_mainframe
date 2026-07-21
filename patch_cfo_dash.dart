import 'dart:io';

void main() {
  final cfoPath = 'lib/screens/cofounder_dashboard.dart';
  final cfoFile = File(cfoPath);
  var lines = cfoFile.readAsLinesSync();

  // Find where stubs start
  final stubIdx = lines.indexWhere(
    (l) => l.contains("String _taskSubTab = 'ALL';"),
  );
  if (stubIdx != -1) {
    lines = lines.sublist(0, stubIdx);
  }

  // Read dialog_extract.txt
  final extractFile = File('dialog_extract.txt');
  final extractLines = extractFile.readAsLinesSync();

  final startIdx = extractLines.indexWhere(
    (l) => l.contains("Widget _buildPersonnelTab() {"),
  );
  if (startIdx != -1) {
    lines.addAll(extractLines.sublist(startIdx));
  }

  // Add closing bracket for class
  lines.add('}');

  cfoFile.writeAsStringSync(lines.join('\n'));
  print('Patched cofounder_dashboard.dart');
}
