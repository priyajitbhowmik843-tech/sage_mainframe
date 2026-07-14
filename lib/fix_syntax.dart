import 'dart:io';

void main() {
  final files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cfo_dashboard.dart',
    'lib/screens/employee_dashboard.dart',
    'lib/screens/videographer_dashboard.dart'
  ];

  final target = '      ),\r\n    );\r\n  }\r\n\r\n  Widget _navIcon';
  final targetLf = '      ),\n    );\n  }\n\n  Widget _navIcon';
  final replacement = '      ),\n    ));\n  }\n\n  Widget _navIcon';
  
  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) continue;
    String content = file.readAsStringSync();
    
    if (content.contains(target)) {
      content = content.replaceFirst(target, replacement);
      file.writeAsStringSync(content);
      print("Fixed CRLF in \$path");
    } else if (content.contains(targetLf)) {
      content = content.replaceFirst(targetLf, replacement);
      file.writeAsStringSync(content);
      print("Fixed LF in \$path");
    } else {
      final regex = RegExp(r'      \),\r?\n    \);\r?\n  \}\r?\n\r?\n  Widget _navIcon');
      if (regex.hasMatch(content)) {
        content = content.replaceFirst(regex, replacement);
        file.writeAsStringSync(content);
        print("Fixed Regex in \$path");
      } else {
        print("Could not find target in \$path!");
      }
    }
  }
}
