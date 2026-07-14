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
    
    // The corrupted UTF-8 '₹' is composed of:
    // U+00E2 (�), U+201A (�), U+00B9 (�)
    content = content.replaceAll('\u00E2\u201A\u00B9', r'\u20B9');
    
    // Sometimes it might be represented as â‚¹ if corrupted twice!
    content = content.replaceAll('\u00C3\u00A2\u00E2\u201A\u00AC\u00C5\u00A1', r'\u20B9');
    
    // Let's also just replace the literal character ₹ if dart sees it as that
    content = content.replaceAll('₹', r'\u20B9');
    content = content.replaceAll('â‚¹', r'\u20B9');
    
    f.writeAsStringSync(content);
    print('Fixed ' + file);
  }
}
