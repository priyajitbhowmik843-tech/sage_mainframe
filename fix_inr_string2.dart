import 'dart:io';
import 'dart:convert';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart') || f.path.endsWith('.txt'));
  
  for (final file in files) {
    try {
      String content = file.readAsStringSync(encoding: const Utf8Codec(allowMalformed: true));
      if (content.contains('\uFFFD,1')) {
        content = content.replaceAll('\uFFFD,1', '₹');
        file.writeAsStringSync(content);
        print('Fixed INR in ${file.path}');
      }
    } catch (e) {
      print('Error on ${file.path}: $e');
    }
  }
}
