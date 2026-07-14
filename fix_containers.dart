import 'dart:io';

void main() {
  final dir = Directory('lib/screens');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (var file in files) {
    var content = file.readAsStringSync();
    var originalContent = content;

    content = content.replaceAll(RegExp(r'width:\s*44,\s*height:\s*44', multiLine: true), 'width: 88, height: 88');
    content = content.replaceAll(RegExp(r'width:\s*70,\s*height:\s*70', multiLine: true), 'width: 140, height: 140');

    if (content != originalContent) {
      file.writeAsStringSync(content);
      print("Updated \${file.path} containers");
    }
  }
}
