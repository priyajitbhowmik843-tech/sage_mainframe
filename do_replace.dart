import 'dart:io';

void main() {
  replacePart(
    'lib/screens/cofounder_dashboard.dart',
    'lib/screens/snippet.dart',
  );
  replacePart(
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/ceo_personnel_part.txt',
  );
}

void replacePart(String dartFile, String snippetFile) {
  var lines = File(dartFile).readAsLinesSync();
  var snippetLines = File(snippetFile).readAsLinesSync();
  int startIdx = -1;
  int endIdx = -1;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains(
          '...AppState.personas.asMap().entries.map((entry) {',
        ) &&
        startIdx == -1) {
      startIdx = i;
    }
    if (lines[i].contains('String _taskSubTab =') && endIdx == -1) {
      endIdx = i - 3;
      break;
    }
  }
  if (startIdx != -1 && endIdx != -1) {
    var newLines = <String>[];
    newLines.addAll(lines.sublist(0, startIdx));
    newLines.addAll(snippetLines);
    newLines.addAll(lines.sublist(endIdx));
    File(dartFile).writeAsStringSync(newLines.join('\n') + '\n');
    print('Fixed ' + dartFile);
  } else {
    print('Indices not found in ' + dartFile);
  }
}
