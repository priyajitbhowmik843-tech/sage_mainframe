import 'dart:io';

void main() {
  final files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cofounder_dashboard.dart',
    'lib/screens/cofounder_dashboard_new.dart',
    'lib/screens/cofounder_dashboard_recovered.dart',
  ];

  for (final file in files) {
    final f = File(file);
    if (!f.existsSync()) continue;

    var content = f.readAsStringSync();

    // Use regex to catch all variants of corrupted prefix before ${employee.phone.isNotEmpty
    content = content.replaceAll(
      RegExp(r'"[^"]*?\$\{employee\.phone\.isNotEmpty'),
      r'"\u{1F4DE} ${employee.phone.isNotEmpty',
    );
    content = content.replaceAll(
      RegExp(r'"[^"]*?\$\{employee\.email\.isNotEmpty'),
      r'"\u{2709} ${employee.email.isNotEmpty',
    );
    content = content.replaceAll(
      RegExp(r'"[^"]*?\$\{employee\.address\.isNotEmpty'),
      r'"\u{1F4CD} ${employee.address.isNotEmpty',
    );

    f.writeAsStringSync(content);
    print('Fixed ' + file);
  }
}
