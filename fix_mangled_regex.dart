import 'dart:io';

void main() {
  final files = [
    'lib/screens/cofounder_dashboard.dart',
  ];

  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) continue;
    
    var lines = file.readAsLinesSync();
    bool changed = false;
    
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('t.deadline.day') && lines[i].contains('_getAssigneeName')) {
        print('Found target in \$path at line \${i+1}');
        final pattern = RegExp(r'\{state\)\}.*?\$\{t\.deadline\.day\}');
        if (pattern.hasMatch(lines[i])) {
          lines[i] = lines[i].replaceAll(pattern, '{state)} • \${t.deadline.day}');
          // Also remove any remaining currency symbols before \${_getAssigneeName
          lines[i] = lines[i].replaceAll(RegExp(r'"[^"]*\$\{\_getAssigneeName'), '"\$\{\_getAssigneeName');
          changed = true;
          print('Fixed: \${lines[i].trim()}');
        }
      }
    }
    
    if (changed) {
      file.writeAsStringSync(lines.join('\n') + '\n');
    }
  }
}
