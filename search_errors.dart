import 'dart:io';

void main() {
  void searchInFile(String path) {
    final file = File(path);
    if (!file.existsSync()) return;

    final lines = file.readAsStringSync().split('\n');
    final regex = RegExp(r'[^(\[\{:,=]\s*"₹\$\{'); 

    for (int i = 0; i < lines.length; i++) {
      if (regex.hasMatch(lines[i])) {
        print('\$path:\${i+1}: \${lines[i].trim()}');
      }
    }
  }

  searchInFile('lib/screens/ceo_dashboard.dart');
  searchInFile('lib/screens/cofounder_dashboard.dart');
  searchInFile('lib/screens/marketing_executive_dashboard.dart');
  searchInFile('lib/state/app_state.dart');
}
