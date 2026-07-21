import 'dart:io';

void main() {
  final files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cofounder_dashboard.dart',
    'lib/state/app_state.dart',
  ];

  for (final file in files) {
    final f = File(file);
    if (!f.existsSync()) continue;

    var content = f.readAsStringSync();

    // The corrupted UTF-8 'â‚¹' is composed of:
    // U+00E2 (â), U+201A (‚), U+00B9 (¹)
    content = content.replaceAll('\u00E2\u201A\u00B9', '\u20B9');

    // Sometimes it might be represented as Ã¢â€šÂ¹ if corrupted twice!
    content = content.replaceAll(
      '\u00C3\u00A2\u20AC\u0161\u00C2\u00B9',
      '\u20B9',
    );

    // Let's also just replace the literal character â‚¹ if dart sees it as that
    content = content.replaceAll('â‚¹', '\u20B9');
    content = content.replaceAll('Ã¢â€šÂ¹', '\u20B9');

    f.writeAsStringSync(content);
    print('Fixed ' + file);
  }
}
