import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') || f.path.endsWith('.txt'));

  for (final file in files) {
    try {
      String content = file.readAsStringSync();
      if (content.contains('\uFFFD,1')) {
        content = content.replaceAll('\uFFFD,1', '₹');
        file.writeAsStringSync(content);
        print('Fixed INR in ${file.path}');
      } else if (content.contains('ï¿½,1')) {
        content = content.replaceAll('ï¿½,1', '₹');
        file.writeAsStringSync(content);
        print('Fixed INR in ${file.path} (alternate encoding)');
      }
    } catch (e) {
      // Ignored
    }
  }
}
