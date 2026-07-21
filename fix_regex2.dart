import 'dart:io';

void main() {
  void fixFile(String path) {
    final file = File(path);
    if (!file.existsSync()) return;

    String content;
    try {
      content = file.readAsStringSync();
    } catch (e) {
      // fallback
      var bytes = file.readAsBytesSync();
      content = String.fromCharCodes(bytes);
    }
    bool changed = false;

    // Fix marketing executive dashboard leads count
    final leadsRegex = RegExp(r'"[^"]*,1\$\{assignedLeads\.length\}\)"');
    if (leadsRegex.hasMatch(content)) {
      content = content.replaceAll(leadsRegex, '"(\${assignedLeads.length})"');
      changed = true;
    }

    // Fix marketing executive dashboard contact phone
    final phoneRegex = RegExp(r'"[^"]*,1\$\{c\.contact\.phone\}\)"');
    if (phoneRegex.hasMatch(content)) {
      content = content.replaceAll(phoneRegex, '"(\${c.contact.phone})"');
      changed = true;
    }

    // Fix marketing executive dashboard pending pay amount
    final payRegex = RegExp(r'[^\x00-\x7F]*,1\$\{emp\.pendingPayAmount');
    if (payRegex.hasMatch(content)) {
      content = content.replaceAll(payRegex, '₹\${emp.pendingPayAmount');
      changed = true;
    }

    // Also try without non-ascii for pay amount just in case
    final payRegex2 = RegExp(r'[^"]*,1\$\{emp\.pendingPayAmount');
    if (payRegex2.hasMatch(content)) {
      content = content.replaceAll(payRegex2, '₹\${emp.pendingPayAmount');
      changed = true;
    }

    // Fix ANY remaining `,1${` in the file which should be `₹${`
    final genericRegex = RegExp(r'[^\x00-\x7F]*,1\$\{');
    if (genericRegex.hasMatch(content)) {
      content = content.replaceAll(genericRegex, '₹\${');
      changed = true;
    }

    // Check if it's literally `,1${` without any special characters before it
    if (content.contains('",1\${emp.pendingPayMonth}')) {
      content = content.replaceAll(
        '",1\${emp.pendingPayMonth}',
        '₹\${emp.pendingPayMonth}',
      );
      changed = true;
    }

    // ceo_dashboard
    if (content.contains('const Column(')) {
      content = content.replaceAll('const Column(', 'Column(');
      changed = true;
    }

    if (changed) {
      file.writeAsStringSync(content);
      print('Fixed regex corruption in \$path');
    }
  }

  fixFile('lib/screens/marketing_executive_dashboard.dart');
  fixFile('lib/screens/ceo_dashboard.dart');
  fixFile('lib/screens/cofounder_dashboard.dart');
  fixFile('lib/state/app_state.dart');
}
