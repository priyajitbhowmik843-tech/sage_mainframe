import 'dart:io';

void main() {
  void fixFile(String path) {
    final file = File(path);
    if (!file.existsSync()) return;

    // Read the file as a string. Dart's readAsStringSync defaults to UTF-8
    String content = file.readAsStringSync();
    bool changed = false;

    // Use a regex to find any sequence of non-ASCII characters immediately preceding a $ sign.
    // For example, â‚¹$ or ,1$ or any mangled currency symbol.
    final regex = RegExp(r'[^\x00-\x7F]+\$\{');

    if (regex.hasMatch(content)) {
      content = content.replaceAll(regex, '₹\${');
      changed = true;
    }

    // Also, we need to fix the case where the replacement added `"` inside the string.
    // E.g. `"I acknowledge that I received "₹\${` -> `"I acknowledge that I received ₹\${`
    if (content.contains('"₹\${')) {
      content = content.replaceAll('received "₹\${', 'received ₹\${');
      content = content.replaceAll('Fee: "₹\${', 'Fee: ₹\${');
      changed = true;
    }

    // Fix the CEO dashboard const Text error.
    if (content.contains('const Text("₹')) {
      content = content.replaceAll('const Text("₹', 'Text("₹');
      changed = true;
    }
    if (content.contains('const Text(\'₹')) {
      content = content.replaceAll('const Text(\'₹', 'Text(\'₹');
      changed = true;
    }

    if (changed) {
      file.writeAsStringSync(content);
      print('Fixed UTF-8 corruption in \$path');
    }
  }

  fixFile('lib/state/app_state.dart');
  fixFile('lib/screens/ceo_dashboard.dart');
  fixFile('lib/screens/cofounder_dashboard.dart');
  fixFile('lib/screens/marketing_executive_dashboard.dart');
}
