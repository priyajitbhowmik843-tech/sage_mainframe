import 'dart:io';

void main() {
  final files = [
    'lib/state/app_state.dart',
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cofounder_dashboard.dart',
  ];

  for (final file in files) {
    final f = File(file);
    if (!f.existsSync()) continue;

    var content = f.readAsStringSync();

    // Replace the corrupted INR symbol
    content = content.replaceAll(RegExp(r'A\xef\xbf\xbd\?sA1'), r'\u20B9');
    content = content.replaceAll(RegExp(r'A\xef\xbf\xbd\?s'), r'\u20B9');

    // Some other variants of corrupted INR
    content = content.replaceAll('A?sA1', r'\u20B9');

    // Look for Amount (garbage)
    content = content.replaceAll(
      RegExp(r'Amount \([^)]+\)'),
      r'Amount (\u20B9)',
    );

    // Also fix the replaceAll logic in dart code
    content = content.replaceAll(
      r"replaceAll('A?sA1', '')",
      r"replaceAll('\u20B9', '')",
    );
    content = content.replaceAll(
      RegExp(r"replaceAll\('A\xef\xbf\xbd\?sA1', ''\)"),
      r"replaceAll('\u20B9', '')",
    );
    content = content.replaceAll(
      RegExp(r"replaceAll\('A\xef\xbf\xbd\?s', ''\)"),
      r"replaceAll('\u20B9', '')",
    );

    f.writeAsStringSync(content);
    print('Fixed ' + file);
  }
}
