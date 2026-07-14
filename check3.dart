import 'dart:io';

void main() {
  void checkFile(String path) {
    final file = File(path);
    if (!file.existsSync()) return;
    
    final lines = file.readAsStringSync().split('\n');
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('(\${')) {
        print('\$path:\${i+1}: \${lines[i].trim()}');
      }
    }
  }

  checkFile('lib/screens/ceo_dashboard.dart');
  checkFile('lib/screens/cofounder_dashboard.dart');
  checkFile('lib/screens/marketing_executive_dashboard.dart');
  checkFile('lib/state/app_state.dart');
}
