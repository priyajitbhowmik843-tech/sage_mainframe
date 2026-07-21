import 'dart:io';

void main() {
  final files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cofounder_dashboard.dart',
  ];

  for (final file in files) {
    final f = File(file);
    if (!f.existsSync()) continue;

    var content = f.readAsStringSync();

    // Replace the corrupted INR symbol (where it was parsed as replacement char)
    content = content.replaceAll('A\uFFFD?sA1', r'\u20B9');

    // Sometimes it's A\uFFFD?s without A1
    content = content.replaceAll('A\uFFFD?s', r'\u20B9');

    // Also replace in replaceAll calls
    content = content.replaceAll(
      r"replaceAll('A\uFFFD?sA1', '')",
      r"replaceAll('\u20B9', '')",
    );
    content = content.replaceAll(
      r"replaceAll('A\uFFFD?s', '')",
      r"replaceAll('\u20B9', '')",
    );

    f.writeAsStringSync(content);
    print('Fixed ' + file);
  }
}
