import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  int count = 0;
  for (final f in files) {
    String content = f.readAsStringSync();
    String newContent = content;

    // Replace any sequence of non-ASCII characters followed immediately by $ with \u20B9$
    newContent = newContent.replaceAll(RegExp(r'[^\x00-\x7F]+\$'), '\\u20B9\$');
    
    // Replace any sequence of non-ASCII characters inside parentheses at the end of label like "Rate ([non-ascii])"
    newContent = newContent.replaceAll(RegExp(r'\([^\x00-\x7F]+\)'), '(\\u20B9)');

    // Replace any ',1$' -> '\u20B9$'
    newContent = newContent.replaceAll(RegExp(r',1\$'), '\\u20B9\$');

    if (content != newContent) {
      f.writeAsStringSync(newContent);
      print('Fixed ${f.path}');
      count++;
    }
  }
  print('Fixed $count files.');
}
