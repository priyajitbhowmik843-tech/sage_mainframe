import 'dart:io';

void main() {
  void fixFile(String path) {
    final file = File(path);
    if (!file.existsSync()) return;
    
    String content = file.readAsStringSync();
    bool changed = false;

    // Pattern: `"..."₹${`
    // This happens when `"some text ("` became `"some text "₹`
    // Wait, if it was `"some text (${var})"`, and `(` became `"₹`, 
    // it became `"some text "₹${var})"`!
    final regex = RegExp(r'"₹\$\{');
    
    // Let's print out all matches to see what they are exactly!
    final lines = content.split('\n');
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('"₹\${')) {
        print('\$path:\${i+1}: \${lines[i].trim()}');
        
        // Let's replace `"₹\${` with `(\${`
        lines[i] = lines[i].replaceAll('"₹\${', '(\${');
        changed = true;
      }
      if (lines[i].contains('\'₹\${')) {
        print('\$path:\${i+1}: \${lines[i].trim()}');
        lines[i] = lines[i].replaceAll('\'₹\${', '(\${');
        changed = true;
      }
    }

    if (changed) {
      file.writeAsStringSync(lines.join('\n'));
      print('Fixed invalid quote before ₹ in \$path');
    }
  }

  fixFile('lib/screens/ceo_dashboard.dart');
  fixFile('lib/screens/cofounder_dashboard.dart');
  fixFile('lib/screens/marketing_executive_dashboard.dart');
  fixFile('lib/state/app_state.dart');
}
