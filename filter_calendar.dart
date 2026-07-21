import 'dart:io';

void main() {
  final files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cofounder_dashboard.dart',
  ];

  for (final path in files) {
    final file = File(path);
    var content = file.readAsStringSync();

    // Replace the simple assignment with a filtered one
    content = content.replaceAll(
      '    final allTasks = state.tasks;\n    final monthNames = [\'JAN\', \'FEB\', \'MAR\', \'APR\', \'MAY\', \'JUN\', \'JUL\', \'AUG\', \'SEP\', \'OCT\', \'NOV\', \'DEC\'];',
      '    final allTasks = state.tasks.where((t) {\n      final title = t.title.toLowerCase();\n      final typeStr = (t.taskType ?? \'\').toLowerCase();\n      return !title.contains(\'upload\') && !typeStr.contains(\'upload\');\n    }).toList();\n    final monthNames = [\'JAN\', \'FEB\', \'MAR\', \'APR\', \'MAY\', \'JUN\', \'JUL\', \'AUG\', \'SEP\', \'OCT\', \'NOV\', \'DEC\'];',
    );

    file.writeAsStringSync(content);
    print("Updated \$path");
  }
}
