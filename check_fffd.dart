import 'dart:io';

void main() {
  final file = File('lib/screens/cofounder_dashboard.dart');
  final lines = file.readAsStringSync().split('\n');
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('\uFFFD')) {
      print('cofounder_dashboard.dart:\${i+1}: \${lines[i].trim()}');
    }
  }
}
