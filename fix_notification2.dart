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

    // Match anything between timeStr and by
    final corruptedPattern = RegExp(
      r'"\$dateStr \$timeStr\s+.*?\s+by \$\{n\.triggeredBy\}"',
    );
    if (corruptedPattern.hasMatch(content)) {
      content = content.replaceAll(
        corruptedPattern,
        '"\$dateStr \$timeStr - by \${n.triggeredBy}"',
      );
      file.writeAsStringSync(content);
      print('Updated \$path');
    } else {
      print('No match in \$path');
    }
  }
}
