import 'dart:io';

void main() {
  void replaceInFile(String path) {
    final file = File(path);
    if (!file.existsSync()) return;

    String content = file.readAsStringSync();
    bool changed = false;

    // Fix mangled symbols before a dollar sign in interpolation
    // e.g. "?\${" -> "Rs. \${"
    final regex = RegExp(r'[^\w\s\+\-\/\:\]\}\)]+\$\{');
    if (regex.hasMatch(content)) {
      content = content.replaceAll(regex, 'Rs. \${');
      changed = true;
    }

    // Fix the specific CEO dashboard salary issue: Text("SALARY: ?\${
    final salaryRegex = RegExp(r'SALARY\:\s*\?\$\{');
    if (salaryRegex.hasMatch(content)) {
      content = content.replaceAll(salaryRegex, 'SALARY: Rs. \${');
      changed = true;
    }

    // Fix the spacing for blocked clients
    if (content.contains('blockingClients.add(c.name);')) {
      content = content.replaceAll(
        'blockingClients.add(c.name);',
        'blockingClients.add(c.name.trim());',
      );
      changed = true;
    }

    if (changed) {
      file.writeAsStringSync(content);
      print('Fixed bugs in \$path');
    }
  }

  replaceInFile('lib/state/app_state.dart');
  replaceInFile('lib/screens/ceo_dashboard.dart');
  replaceInFile('lib/screens/cofounder_dashboard.dart');
  replaceInFile('lib/screens/marketing_executive_dashboard.dart');
}
