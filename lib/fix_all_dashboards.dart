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

    // 1. Remove WillPopScope wrapper if it exists
    final willPopRegex = RegExp(r'return WillPopScope\([\s\S]*?child:\s*Scaffold\(');
    content = content.replaceFirst(willPopRegex, 'return Scaffold(');

    // 2. Remove all consecutive `);\s*);\s*` and replace with `);\n  }` at the end of build method
    // We can just find `\r?\n    \);\r?\n    \);\r?\n` and replace it down to a single `\n    );\n`
    // Actually, we can just collapse any sequence of `);\n` that appears before `  }\n\n  `
    
    final methodStartRegex = RegExp(r'(?:\r?\n\s*\);)+\r?\n  \}\r?\n\r?\n  (Widget|Color|String|bool|void|List) _');
    content = content.replaceFirstMapped(methodStartRegex, (match) {
      return '\n    );\n  }\n\n  ${match.group(1)} _';
    });
    
    // Also fix the stray `);` injected into random methods like _showEditPersonalDetailsDialog
    // If there is `\n    );\n    );\n  }\n\n  void _show`, we collapse it.
    final randomMethodRegex = RegExp(r'(?:\r?\n\s*\);)+\r?\n  \}\r?\n\r?\n  (void|Widget) _show');
    content = content.replaceFirstMapped(randomMethodRegex, (match) {
      return '\n    );\n  }\n\n  ${match.group(1)} _show';
    });
    
    // NOW, apply the correct wrapper!
    if (content.contains('return Scaffold(')) {
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
      
      // Now correctly close the Scaffold and WillPopScope at the end of the build method
      // The end of the build method is currently `\n    );\n  }\n\n  (Widget|Color|...`
      final buildEndRegex = RegExp(r'\r?\n    \);\r?\n  \}\r?\n\r?\n  (Widget|Color|String|bool|void|List) _');
      content = content.replaceFirstMapped(buildEndRegex, (match) {
        return '\n    ),\n    );\n  }\n\n  ${match.group(1)} _';
      });
    }

    f.writeAsStringSync(content);
    print('Cleaned and Fixed \$file');
  }
}
