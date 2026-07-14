import 'dart:io';

void main() {
  final content = File('lib/screens/cofounder_dashboard.dart').readAsStringSync();
  if (content.contains('\uFFFD')) {
    print('Still contains UFFFD!');
  } else {
    print('Clean!');
  }
}
