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
    if (braceCount == 0 && i > 100) {
      print('Brace count hit 0 at line \$i: \$line');
      return;
    }
  }
}
