import 'dart:io';

void main() {
  final file = File('lib/screens/videographer_dashboard.dart');
  String content = file.readAsStringSync();
  
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
    
    // The end of the build method in videographer_dashboard.dart is before `Widget _buildActiveTab`
    // Originally, it's `    );\n  }\n\n  Widget _buildActiveTab`
    // We want it to be `    ),\n    );\n  }\n\n  Widget _buildActiveTab`
    final buildEndRegex = RegExp(r'\r?\n    \);\r?\n  \}\r?\n\r?\n  Widget _buildActiveTab');
    content = content.replaceFirstMapped(buildEndRegex, (match) {
      return '\n    ),\n    );\n  }\n\n  Widget _buildActiveTab';
    });
    
    file.writeAsStringSync(content);
    print("Fixed videographer back button!");
  }
}
