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

    // Check if it already has WillPopScope. If not, it means my previous script didn't even run on it?
    // It should have it.
    if (!content.contains('WillPopScope(')) continue;

    // We want to insert `\n    );` right before `\n  }\n\n  ` where the next method starts.
    // To handle \r\n vs \n, we can use \r?\n.
    final methodStartRegex = RegExp(
      r'\r?\n  \}\r?\n\r?\n  (Widget|Color|String|bool|void|List) _',
    );

    // Check if we ALREADY added it (in case we run this multiple times)
    // If we already have `\r?\n    \);\r?\n  \}` we don't need to add another unless we need to.
    // Actually, originally it had ONE `);\r?\n  }`. We need TWO `);\r?\n    );\r?\n  }`.
    // So if it doesn't match `\);\r?\n    \);\r?\n  \}`, we replace it.

    bool changed = false;
    content = content.replaceFirstMapped(methodStartRegex, (match) {
      changed = true;
      return '\n    );\n  }\n\n  ${match.group(1)} _';
    });

    if (changed) {
      f.writeAsStringSync(content);
      print('Fixed parenthesis in \$file');
    } else {
      print('Could not find method start in \$file');
    }
  }
}
