import 'dart:io';

void main() {
  final files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cofounder_dashboard.dart',
  ];

  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) continue;
    var content = file.readAsStringSync();

    // 1. Fix corrupted text in notifications
    content = content.replaceAll(
      r'Text(',
      'Text('
    ); // just for spacing sanity check
    
    // We'll use a regex because the corrupted string might have weird characters
    final notificationBugPattern = RegExp(r'"\$dateStr \$timeStr[^"]+by \$\{n\.triggeredBy\}"');
    content = content.replaceAll(notificationBugPattern, '"\$dateStr \$timeStr • by \${n.triggeredBy}"');

    // 2. Fix the Paid Till tracker to show only the last cleared month
    final oldPaidTill = r'Text("Paid Till: ${employee.paidMonths.join(", ")}"';
    final newPaidTill = r'''Text("Paid Till: ${employee.paidMonths.isEmpty ? 'None' : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'].lastWhere((m) => employee.paidMonths.contains(m), orElse: () => employee.paidMonths.last)}"''';
    content = content.replaceAll(oldPaidTill, newPaidTill);

    file.writeAsStringSync(content);
    print('Updated \$path');
  }
}
