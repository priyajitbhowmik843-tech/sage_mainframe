import 'dart:io';

void main() {
  final file = File('lib/screens/ceo_dashboard.dart');
  String content = file.readAsStringSync();

  final target = '      ),\r\n    );\r\n  }\r\n\r\n  Color _getHeaderColor';
  final targetLf = '      ),\n    );\n  }\n\n  Color _getHeaderColor';
  final replacement = '      ),\n    ));\n  }\n\n  Color _getHeaderColor';

  if (content.contains(target)) {
    content = content.replaceFirst(target, replacement);
    print("Replaced CRLF");
  } else if (content.contains(targetLf)) {
    content = content.replaceFirst(targetLf, replacement);
    print("Replaced LF");
  } else {
    final regex = RegExp(
      r'      \),\r?\n    \);\r?\n  \}\r?\n\r?\n  Color _getHeaderColor',
    );
    if (regex.hasMatch(content)) {
      content = content.replaceFirst(regex, replacement);
      print("Replaced Regex");
    } else {
      print("Could not find target!");
    }
  }

  file.writeAsStringSync(content);
}
