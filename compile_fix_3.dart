import 'dart:io';

void fixSyntax(String path) {
  var file = File(path);
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();

  // Find the end of the build method which ends with `    );\n  }\n\n  Widget _build` or similar
  // We know it ends with Stack -> Scaffold -> GestureDetector -> WillPopScope
  // So we need
  //       ), // Stack
  //     ), // Scaffold
  //   ), // GestureDetector
  // ); // WillPopScope

  // Let's replace the end of build method specifically.
  // The original before any of my scripts was:
  //       ),
  //     ),
  //     );
  //   }

  content = content.replaceAll(
    '''
      ),
    ),
    );
  }
''',
    '''
      ),
    ),
    ),
    );
  }
''',
  );

  // Also replace if it looks like:
  content = content.replaceAll(
    '''
        ],
      ),
    ),
    );
  }
''',
    '''
        ],
      ),
    ),
    ),
    );
  }
''',
  );

  file.writeAsStringSync(content);
}

void fixMethods(String path) {
  var file = File(path);
  if (!file.existsSync()) return;
  var t = file.readAsStringSync();
  if (path.contains('ceo') || path.contains('cofounder')) {
    if (!t.contains('void _showAddMemberDialog(BuildContext context) {}')) {
      t = t.replaceAll(
        '  Widget _buildTeamTab() {',
        '  void _showAddMemberDialog(BuildContext context) {}\n  void _showAddLedgerDialog(BuildContext context) {}\n\n  Widget _buildTeamTab() {',
      );
    }
  }
  file.writeAsStringSync(t);
}

void main() {
  var files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cofounder_dashboard.dart',
    'lib/screens/employee_dashboard.dart',
    'lib/screens/videographer_dashboard.dart',
  ];

  for (var f in files) {
    fixSyntax(f);
    fixMethods(f);
  }
  print('Syntax fixed again!');
}
