import 'dart:io';

void main() {
  final files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cofounder_dashboard.dart',
  ];

  for (final path in files) {
    final file = File(path);
    var content = file.readAsStringSync();

    content = content.replaceAll(
      'String localServiceType = c.serviceType.toLowerCase().contains(\'commerce\') ? \'E-Commerce\' : c.serviceType;',
      'String localServiceType = \'Marketing\';',
    );

    file.writeAsStringSync(content);
    print("Fixed \$path");
  }
}
