import 'dart:io';
import 'dart:convert';

void main() {
  void fixFile(String path) {
    final file = File(path);
    if (!file.existsSync()) return;
    
    String content = file.readAsStringSync();
    bool changed = false;

    // Use \uFFFD for the replacement character
    if (content.contains('\uFFFD,1\${')) {
      content = content.replaceAll('"\uFFFD,1\${assignedLeads.length})"', '(\${assignedLeads.length})');
      content = content.replaceAll('"\uFFFD,1\${c.contact.phone})"', '(\${c.contact.phone})');
      content = content.replaceAll('\uFFFD,1\${emp.pendingPayAmount', '₹\${emp.pendingPayAmount');
      content = content.replaceAll('\uFFFD,1\${', '₹\${');
      changed = true;
    }

    if (content.contains('const Column(')) {
      content = content.replaceAll('const Column(', 'Column(');
      changed = true;
    }

    if (changed) {
      file.writeAsStringSync(content);
      print('Fixed \uFFFD corruption in \$path');
    }
  }

  fixFile('lib/screens/marketing_executive_dashboard.dart');
  fixFile('lib/screens/ceo_dashboard.dart');
  fixFile('lib/screens/cofounder_dashboard.dart');
  fixFile('lib/state/app_state.dart');
}
