import 'dart:io';

void main() {
  final files = ['ceo_dashboard.dart', 'cofounder_dashboard.dart'];
  for (final file in files) {
    final f = File(file);
    String content = f.readAsStringSync();
    content = content.replaceAll('Ã¢â€šÂ¹', '₹');
    f.writeAsStringSync(content);
  }
}
