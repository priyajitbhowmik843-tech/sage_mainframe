import 'dart:io';
import 'dart:convert';

void main() {
  void fixFile(String path) {
    final file = File(path);
    if (!file.existsSync()) return;
    
    String content = file.readAsStringSync(encoding: utf8);
    bool changed = false;

    // Fix missing opening parenthesis for Text widget
    if (content.contains('Text"₹')) {
      content = content.replaceAll('Text"₹', 'Text("₹');
      changed = true;
    }
    
    // Also look for `Text",1` or `Text",1` or whatever it might be
    if (content.contains('Text"')) {
      content = content.replaceAll('Text",1', 'Text("₹');
      content = content.replaceAll('Text",1', 'Text("₹');
      changed = true;
    }

    if (content.contains('Text\'₹')) {
      content = content.replaceAll('Text\'₹', 'Text(\'₹');
      changed = true;
    }

    // Since I know my regex `fix_regex.dart` ran, it probably already changed `,1` to `₹`
    // So `Text",1` probably became `Text"₹`! Which is covered by `Text"₹` -> `Text("₹`.

    if (changed) {
      file.writeAsStringSync(content, encoding: utf8);
      print('Fixed Text missing parenthesis in \$path');
    }
  }

  fixFile('lib/screens/ceo_dashboard.dart');
  fixFile('lib/screens/cofounder_dashboard.dart');
  fixFile('lib/screens/marketing_executive_dashboard.dart');
}
