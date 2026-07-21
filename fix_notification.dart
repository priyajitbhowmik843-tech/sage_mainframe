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

    // Replace the corrupted string using a more relaxed regex
    final corruptedPattern = RegExp(
      r'"\$dateStr \$timeStr[^"]+by \$\{n\.triggeredBy\}"',
    );
    content = content.replaceAll(
      corruptedPattern,
      '"\$dateStr \$timeStr • by \${n.triggeredBy}"',
    );

    file.writeAsStringSync(content);
    print('Updated \$path');
  }
}
