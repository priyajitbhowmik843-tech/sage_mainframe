import 'dart:io';

void main() {
  final files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cofounder_dashboard.dart',
  ];

  for (final path in files) {
    final file = File(path);
    var content = file.readAsStringSync();
    
    // CEO Review tab
    content = content.replaceAllMapped(
      RegExp(r'children: pendingTasks\.map\(\(t\) \{\s+final submissionDateStr ='),
      (match) => 'children: pendingTasks.map((t) {\\n          Color typeColor = Colors.black;\\n          final submissionDateStr ='.replaceAll('\\n', '\n')
    );
    
    // CEO & CFO Completed tab
    content = content.replaceAllMapped(
      RegExp(r'children: completedTasks\.take\(50\)\.map\(\(t\) \{[^\n]*\s+return Container\('),
      (match) => 'children: completedTasks.take(50).map((t) { // Limit to 50 for performance\\n          Color typeColor = Colors.black;\\n          return Container('.replaceAll('\\n', '\n')
    );
    
    // CFO Review tab
    content = content.replaceAllMapped(
      RegExp(r'children: pendingTasks\.map\(\(t\) \{\s+return Container\('),
      (match) => 'children: pendingTasks.map((t) {\\n          Color typeColor = Colors.black;\\n          return Container('.replaceAll('\\n', '\n')
    );

    file.writeAsStringSync(content);
    print("Updated $path");
  }
}
