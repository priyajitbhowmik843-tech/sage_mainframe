import 'dart:io';

void main() {
  var dir = Directory('lib');
  var files = dir.listSync(recursive: true);
  for (var entity in files) {
    if (entity is File && entity.path.endsWith('.dart')) {
      var content = entity.readAsStringSync();
      var newContent = content.replaceAll('Rs.', '₹').replaceAll('Rs ', '₹');
      if (content != newContent) {
        entity.writeAsStringSync(newContent);
        print('Updated \${entity.path}');
      }
    }
  }
}
