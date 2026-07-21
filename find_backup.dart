import 'dart:io';
import 'dart:convert';

void main() {
  var dir = Directory(
    'C:\\Users\\Priyajit Bhowmik\\.gemini\\antigravity\\brain',
  );
  var files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('transcript_full.jsonl'));
  for (var f in files) {
    var lines = f.readAsLinesSync();
    for (var line in lines) {
      try {
        var json = jsonDecode(line);
        if (json['content'] != null &&
            json['content'].contains('class VideographerDashboard')) {
          print('FOUND IN: ' + f.path);
          print(json['content'].substring(0, 100));
        }
      } catch (e) {}
    }
  }
}
