import 'dart:io';

void main() {
  final file = File('C:\\Users\\Priyajit Bhowmik\\Downloads\\extracted_video.txt');
  final lines = file.readAsLinesSync();
  final outLines = <String>[];
  
  bool started = false;
  for (var line in lines) {
    if (line.startsWith('1: ')) {
      started = true;
    }
    if (started) {
      if (line.startsWith('The above content does NOT show the entire file contents')) {
        break;
      }
      final regex = RegExp(r'^(\d+): (.*)');
      final match = regex.firstMatch(line);
      if (match != null) {
        outLines.add(match.group(2)!);
      } else {
        outLines.add(line);
      }
    }
  }
  
  File('lib/screens/videographer_dashboard_partial.dart').writeAsStringSync(outLines.join('\n'));
}
