import 'dart:io';
import 'dart:convert';

void main() {
  void fixFile(String path) {
    final file = File(path);
    if (!file.existsSync()) return;

    // Read bytes and decode
    var bytes = file.readAsBytesSync();
    String content;
    try {
      content = utf8.decode(bytes);
    } catch (e) {
      content = utf8.decode(bytes, allowMalformed: true);
    }

    bool changed = false;

    // The corruption is exactly: `",1\${` which used to be `(\${`
    // Wait, the original code was: `Text("ASSIGNED LEADS (\${assignedLeads.length})"`
    // And it became: `Text("ASSIGNED LEADS ",1\${assignedLeads.length})"`
    // So the corrupted string is `",1\${` (which powershell prints as `",1\${`)
    // If I just find ` "\xef\xbf\xbd,1\${` and replace it with ` (\${`
    // Let's use regex that matches a quote, any non-ascii, maybe a comma and a 1, and \${

    final brokenRegex = RegExp(r'"[^\x00-\x7F]*,1\$\{');
    if (brokenRegex.hasMatch(content)) {
      content = content.replaceAll(brokenRegex, '(\${');
      changed = true;
    }

    // There's also `Contact: \${c.contact.name} ",1\${c.contact.phone})"`
    // Wait, `Contact: \${c.contact.name} (\${c.contact.phone})"`
    // So ` ",1\${` needs to be ` (\${`
    final brokenRegex2 = RegExp(r' "[^\x00-\x7F]+,1\$\{');
    if (brokenRegex2.hasMatch(content)) {
      content = content.replaceAll(brokenRegex2, ' (\${');
      changed = true;
    }

    // Also we need to fix `ceo_dashboard.dart` where `children: [` became invalid.
    // Wait, if it wasn't a `const Column`, then why was `children: [` non-const?
    // Let's remove ALL `const` from `Text("₹` just in case.
    if (content.contains('const Text("₹')) {
      content = content.replaceAll('const Text("₹', 'Text("₹');
      changed = true;
    }

    // And if `const Column` is there...
    // Let's just strip `const ` from `const Column(` if it contains `₹` inside it.
    if (content.contains('const Column(')) {
      content = content.replaceAll('const Column(', 'Column(');
      changed = true;
    }

    if (changed) {
      file.writeAsStringSync(content);
      print('Fixed more corruption in \$path');
    }
  }

  fixFile('lib/screens/marketing_executive_dashboard.dart');
  fixFile('lib/screens/ceo_dashboard.dart');
  fixFile('lib/screens/cofounder_dashboard.dart');
  fixFile('lib/state/app_state.dart');
}
