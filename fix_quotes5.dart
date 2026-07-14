import 'dart:io';

void main() {
  void fixQuotes(String path) {
    final file = File(path);
    if (!file.existsSync()) return;

    final lines = file.readAsStringSync().split('\n');
    bool changed = false;

    for (int i = 0; i < lines.length; i++) {
      int quoteCount = 0;
      for (int j = 0; j < lines[i].length; j++) {
        if (lines[i][j] == '"') {
          // ignore escaped quotes if any, but unlikely in this simple case
          if (j == 0 || lines[i][j - 1] != '\\') {
            quoteCount++;
          }
        }
      }

      if (quoteCount % 2 != 0) {
        // Odd number of quotes! We probably removed one before ₹\${
        if (lines[i].contains('₹\${')) {
          lines[i] = lines[i].replaceAll('₹\${', '"₹\${');
          changed = true;
          print('Restored quote in \$path at line \${i+1}');
        } else if (lines[i].contains('(\${')) {
          // Maybe we replaced `"₹\${` with `(\${` and removed a quote?
          lines[i] = lines[i].replaceAll('(\${', '"(\${');
          changed = true;
          print('Restored quote before ( in \$path at line \${i+1}');
        }
      }
    }

    if (changed) {
      file.writeAsStringSync(lines.join('\n'));
    }
  }

  fixQuotes('lib/screens/ceo_dashboard.dart');
  fixQuotes('lib/screens/cofounder_dashboard.dart');
  fixQuotes('lib/screens/marketing_executive_dashboard.dart');
  fixQuotes('lib/state/app_state.dart');
}
