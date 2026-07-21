import 'dart:io';

void main() {
  void fixFile(String path) {
    final file = File(path);
    if (!file.existsSync()) return;

    final lines = file.readAsStringSync().split('\n');
    bool changed = false;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('(\${')) {
        // If it looks like `Text((${` or `value: (${` or `Text(  (${`
        if (lines[i].contains('Text(\${') ||
            lines[i].contains('Text( (\${') ||
            lines[i].contains('value: (\${') ||
            lines[i].contains('label: (\${') ||
            lines[i].contains('Text((\${') ||
            lines[i].contains('value:(\${') ||
            lines[i].contains('Text ( (\${')) {
          lines[i] = lines[i].replaceAll('(\${', '"₹\${');
          changed = true;
          print('Fixed in ' + path + ' line ' + (i + 1).toString());
        }
      }
    }
    if (changed) {
      file.writeAsStringSync(lines.join('\n'));
    }
  }

  fixFile('lib/screens/ceo_dashboard.dart');
  fixFile('lib/screens/cofounder_dashboard.dart');
  fixFile('lib/screens/marketing_executive_dashboard.dart');
  fixFile('lib/state/app_state.dart');
}
