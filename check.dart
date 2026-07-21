import 'dart:io';

void main() {
  final f = File('lib/screens/ceo_dashboard.dart').readAsStringSync();
  final lines = f.split('\n');
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains('(\${')) {
      print('ceo_dashboard.dart:\${i+1}: \${lines[i].trim()}');
    }
  }
}
