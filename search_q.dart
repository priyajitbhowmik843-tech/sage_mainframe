import 'dart:io';

void main() {
  final files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cofounder_dashboard.dart',
    'lib/screens/marketing_executive_dashboard.dart',
    'lib/state/app_state.dart',
  ];

  for (final file in files) {
    final lines = File(file).readAsLinesSync();
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('?\$')) {
        print('\$file:\${i + 1}: \${lines[i].trim()}');
      }
    }
  }
}
