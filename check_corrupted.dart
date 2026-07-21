import 'dart:io';
import 'dart:convert';

void main() {
  final dir = Directory('lib');
  for (final file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      final bytes = file.readAsBytesSync();
      final content = utf8.decode(bytes, allowMalformed: true);
      if (content.contains('\xef\xbf\xbd')) {
        print('Found corrupted character in: ' + file.path);
      }
    }
  }
}
