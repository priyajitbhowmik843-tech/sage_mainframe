import 'dart:io';
void main() {
  final f = File('lib/screens/cofounder_dashboard.dart').readAsStringSync();
  final lines = f.split('\n');
  print(lines[1777].trim());
}
