import 'dart:io';

void main() {
  final path = 'lib/screens/ceo_dashboard.dart';
  final file = File(path);
  if (!file.existsSync()) return;
  
  var lines = file.readAsLinesSync();
  bool changed = false;
  
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('t.deadline.day') && lines[i].contains('_getAssigneeName')) {
      final leadingSpaces = lines[i].substring(0, lines[i].indexOf('Text('));
      lines[i] = leadingSpaces + 'Text("\${_getAssigneeName(t.assignedTo, state)} • \${t.deadline.day}/\${t.deadline.month}", style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.bold)),';
      changed = true;
      print('Fixed line \${i+1} in \$path');
    }
  }
  
  if (changed) {
    file.writeAsStringSync(lines.join('\n') + '\n');
  }
}
