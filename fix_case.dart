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
      "serviceType == 'E-Commerce'",
      "serviceType.toLowerCase().contains('commerce')",
    );

    content = content.replaceAll(
      "c.serviceType == 'E-Commerce'",
      "c.serviceType.toLowerCase().contains('commerce')",
    );

    content = content.replaceAll(
      "localServiceType == 'E-Commerce'",
      "localServiceType.toLowerCase().contains('commerce')",
    );

    file.writeAsStringSync(content);
    print("Updated \$path");
  }
}
