import 'dart:io';
import 'dart:convert';

void main() {
  void fixFile(String path) {
    final file = File(path);
    if (!file.existsSync()) return;
    
    String content = file.readAsStringSync(encoding: utf8);
    bool changed = false;

    // Fix specific known broken strings
    if (content.contains(',1\${')) {
      // 1. "ASSIGNED LEADS ",1\${assignedLeads.length})"
      content = content.replaceAll('",1\${assignedLeads.length})"', '(\${assignedLeads.length})');
      // 2. "Contact: \${c.contact.name} ",1\${c.contact.phone})"
      content = content.replaceAll('",1\${c.contact.phone})"', '(\${c.contact.phone})');
      // 3. "I acknowledge that I received ,1\${emp.pendingPayAmount...
      content = content.replaceAll(',1\${emp.pendingPayAmount', '₹\${emp.pendingPayAmount');
      // 4. Any other ,1\${ is probably just ₹\${
      content = content.replaceAll(',1\${', '₹\${');
      changed = true;
    }

    // Fix ceo_dashboard const Column error
    // lib/screens/ceo_dashboard.dart:2685:35: Error: Not a constant expression.
    if (content.contains('const Column(')) {
      content = content.replaceAll('const Column(', 'Column(');
      changed = true;
    }
    
    // Fix cofounder_dashboard const Column error
    // lib/screens/cofounder_dashboard.dart:1746:35: Error: Not a constant expression.
    if (content.contains('const Column(')) {
      content = content.replaceAll('const Column(', 'Column(');
      changed = true;
    }

    // Fix unexpected bracket in marketing_executive_dashboard
    // Error: Unexpected token ';' at `],`
    // Wait, earlier we found:
    //         if (pendingClients.isEmpty && activeClients.isNotEmpty) ...[
    //           const SizedBox(height: 8),
    //           const Row(
    //             children: [
    // This is around line 640. 
    // What about line 399? `],`
    // Let's print out the file line by line to fix it.

    if (changed) {
      file.writeAsStringSync(content, encoding: utf8);
      print('Fixed  corruption in \$path');
    }
  }

  fixFile('lib/screens/marketing_executive_dashboard.dart');
  fixFile('lib/screens/ceo_dashboard.dart');
  fixFile('lib/screens/cofounder_dashboard.dart');
  fixFile('lib/state/app_state.dart');
}
