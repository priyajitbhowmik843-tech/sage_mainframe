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
      if (content.contains('â‚¹')) {
        content = content.replaceAll('â‚¹', '₹');
        file.writeAsStringSync(content);
        print('Fixed INR in ${file.path}');
      }
    } catch (e) {
      // Ignore
    }
  }
}
