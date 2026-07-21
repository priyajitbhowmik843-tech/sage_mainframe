import 'dart:io';

void main() {
  final file = File('lib/screens/videographer_dashboard.dart');
  String content = file.readAsStringSync();

  final startRegex = RegExp(
    r'\s*Text\(statusText, style: TextStyle\(fontSize: 10, color: statusColor, fontWeight: FontWeight\.bold, letterSpacing: 0\.5\)\),',
  );
  final endRegex = RegExp(
    r'        \}\)\.toList\(\),\r?\n      \),\r?\n    \);\r?\n  \}',
  );

  final matchStart = startRegex.firstMatch(content);
  final matchEnd = endRegex.firstMatch(content);

  if (matchStart != null && matchEnd != null) {
    final startIndex = matchStart.start;
    final endIndex = matchEnd.end;

    if (startIndex < endIndex) {
      final replacement = '''              );
            },
          ),
        ),
      ],
    );
  }''';

      content = content.replaceRange(startIndex, endIndex, replacement);
      file.writeAsStringSync(content);
      print("Fixed stray code block successfully!");
    } else {
      print("Start index is after end index!");
    }
  } else {
    print("Could not find start or end matches!");
  }
}
