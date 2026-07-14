import 'dart:io';

void main() {
  final file = File('lib/screens/cofounder_dashboard.dart');
  final lines = file.readAsStringSync().split('\n');
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('Salary: ')) {
      print('Line ' + (i+1).toString() + ': ' + lines[i].trim());
      print('Bytes: ' + lines[i].trim().codeUnits.toString());
    }
  }
}
