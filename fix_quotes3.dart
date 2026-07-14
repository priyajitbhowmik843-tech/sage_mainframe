import 'dart:io';

void main() {
  void fixFile(String path) {
    final file = File(path);
    if (!file.existsSync()) return;
    
    final lines = file.readAsStringSync().split('\n');
    bool changed = false;
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('(\${')) {
        // Exclude the known valid ones which are actually inside a string
        if (lines[i].contains('"ASSIGNED LEADS (\${') || 
            lines[i].contains('"MY LEADS (\${') || 
            lines[i].contains('} (\${')) {
          continue;
        }
        
        // Everything else must be a typo caused by my replaceAll('"₹\${', '(\${')
        lines[i] = lines[i].replaceAll('(\${', '"₹\${');
        changed = true;
        print('Fixed reverted quote in \$path line \${i+1}');
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
