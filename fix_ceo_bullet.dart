import 'dart:io';

void main() {
  final path = 'lib/screens/ceo_dashboard.dart';
  final file = File(path);
  if (!file.existsSync()) return;

  var lines = file.readAsLinesSync();
  bool changed = false;

  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('t.deadline.day') &&
        lines[i].contains('_getAssigneeName')) {
      final pattern = RegExp(r'\{state\)\}.*?\$\{t\.deadline\.day\}');
      if (pattern.hasMatch(lines[i])) {
        lines[i] = lines[i].replaceAll(
          pattern,
          '{state)} • \${t.deadline.day}',
        );
        changed = true;
        print('Fixed line \${i+1} in \$path');
      }
    }
  }

  if (changed) {
    file.writeAsStringSync(lines.join('\n') + '\n');
  }
}
