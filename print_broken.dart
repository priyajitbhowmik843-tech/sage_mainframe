import 'dart:io';
import 'dart:convert';

void main() {
  void printLines(String path, int start, int end) {
    final file = File(path);
    if (!file.existsSync()) return;
    
    final lines = file.readAsLinesSync(encoding: utf8);
    print('--- \$path ---');
    for (int i = start - 1; i < end && i < lines.length; i++) {
      print('\${i + 1}: \${lines[i]}');
    }
    print('');
  }

  printLines('lib/screens/marketing_executive_dashboard.dart', 390, 430);
  printLines('lib/screens/marketing_executive_dashboard.dart', 540, 555);
  printLines('lib/screens/ceo_dashboard.dart', 2680, 2690);
  printLines('lib/screens/ceo_dashboard.dart', 2700, 2710);
  printLines('lib/screens/cofounder_dashboard.dart', 1740, 1750);
  printLines('lib/screens/cofounder_dashboard.dart', 1760, 1770);
}
