import 'dart:io';

void main() {
  final content = File('lib/screens/ceo_dashboard.dart').readAsStringSync();
  final index = content.indexOf('persona.name.toUpperCase');
  if (index != -1) {
    final substring = content.substring(index - 10, index);
    print(substring);
    print(substring.codeUnits);
  }
}
