import 'dart:io';

void main() {
  final file = File('lib/screens/ceo_dashboard.dart');
  final lines = file.readAsStringSync().split('\n');
  print('Line 510: ' + lines[509].trim());
}
