import 'dart:io';

void main() {
  final files = [
    'lib/screens/cofounder_dashboard.dart',
    'lib/screens/cofounder_dashboard_recovered.dart',
  ];

  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) continue;
    
    var lines = file.readAsLinesSync();
    bool changed = false;
    
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('t.deadline.day') && lines[i].contains('_getAssigneeName')) {
        // Just replace the entire line with the correct one
        final leadingSpaces = lines[i].substring(0, lines[i].indexOf('Text('));
        lines[i] = leadingSpaces + 'Text("\${_getAssigneeName(t.assignedTo, state)} • \${t.deadline.day}/\${t.deadline.month}", style: TextStyle(color: Colors.red.shade700, fontSize: 10, fontWeight: FontWeight.bold)),';
        changed = true;
        print('Fixed line \${i+1} in \$path');
      }
    }
    
    if (changed) {
      file.writeAsStringSync(lines.join('\n') + '\n');
    }
  }
}
