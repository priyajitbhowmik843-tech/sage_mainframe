import 'dart:io';

void main() {
  final dir = Directory('lib/screens');
  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  for (var file in files) {
    var content = file.readAsStringSync();
    var originalContent = content;

    content = content.replaceAll(
      'width: 24, height: 24',
      'width: 48, height: 48',
    );
    content = content.replaceAll(
      'width: 44, height: 44',
      'width: 88, height: 88',
    );
    content = content.replaceAll(
      'width: 44,\n                  height: 44,',
      'width: 88,\n                  height: 88,',
    );
    content = content.replaceAll(
      'width: 70,\n                    height: 70,',
      'width: 140,\n                    height: 140,',
    );

    if (content != originalContent) {
      file.writeAsStringSync(content);
      print("Updated \${file.path}");
    }
  }
}
