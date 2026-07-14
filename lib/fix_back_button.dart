import 'dart:io';

void main() {
  final files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cofounder_dashboard.dart',
    'lib/screens/cofounder_dashboard_new.dart',
    'lib/screens/cofounder_dashboard_recovered.dart',
    'lib/screens/employee_dashboard.dart',
    'lib/screens/marketing_executive_dashboard.dart',
    'lib/screens/videographer_dashboard.dart',
  ];

  for (final file in files) {
    final f = File(file);
    if (!f.existsSync()) continue;
    String content = f.readAsStringSync();

    if (content.contains('WillPopScope(')) continue;

    final willPopScopeString = '''return WillPopScope(
      onWillPop: () async {
        if (_tab != 0) {
          setState(() => _tab = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(''';
      
    content = content.replaceFirst('return Scaffold(', willPopScopeString);

    // Find the end of the build method by looking for the FIRST method declaration after build
    // Because build is usually the first method.
    // Methods usually start with `  Widget _`, `  Color _`, `  String _`, `  void _`, `  bool _`
    final methodStartRegex = RegExp(r'\n  \}\n\n  (Widget|Color|String|bool|void) _');
    content = content.replaceFirstMapped(methodStartRegex, (match) {
      return '\n    );\n  }\n\n  ${match.group(1)} _';
    });

    f.writeAsStringSync(content);
    print('Updated \$file');
  }
}
