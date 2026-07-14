import 'dart:io';
import 'dart:convert';

void main() {
  final brainDir = Directory(r"C:\Users\Priyajit Bhowmik\.gemini\antigravity\brain");
  final transcripts = <File>[];
  
  if (brainDir.existsSync()) {
    for (var entity in brainDir.listSync()) {
      if (entity is Directory) {
        final logsDir = Directory('${entity.path}\\.system_generated\\logs');
        if (logsDir.existsSync()) {
          final file = File('${logsDir.path}\\transcript_full.jsonl');
          if (file.existsSync()) {
            transcripts.add(file);
          }
        }
      }
    }
  }

  transcripts.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
  final latest = transcripts.take(5).toList();

  final out = File('RECOVERED_CODE.txt');
  final sink = out.openWrite();

  for (var t in latest) {
    sink.writeln('\n\n========================================\nFROM: ${t.path}\n========================================\n');
    try {
      final lines = t.readAsLinesSync();
      for (var line in lines) {
        try {
          final data = jsonDecode(line);
          final content = data['content'];
          if (content != null && content.toString().contains('VideographerDashboard')) {
            sink.writeln('\n\n--- MATCH FOUND ---\n');
            sink.writeln(content);
          }
          if (data['tool_calls'] != null) {
            for (var tc in data['tool_calls']) {
              final name = tc['name'];
              if (name == 'replace_file_content' || name == 'write_to_file' || name == 'multi_replace_file_content') {
                final args = tc['arguments'];
                if (args != null && args.toString().contains('employee_dashboard')) {
                  sink.writeln('\n\n--- TOOL CALL MATCH FOUND ---\n');
                  sink.writeln(jsonEncode(args));
                }
              }
            }
          }
        } catch (e) {
          // ignore
        }
      }
    } catch (e) {
      sink.writeln('Error reading: $e');
    }
  }

  sink.close();
  print('Saved to RECOVERED_CODE.txt');
}
