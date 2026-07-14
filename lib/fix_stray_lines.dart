import 'dart:io';

void main() {
  final file = File('lib/screens/videographer_dashboard.dart');
  final lines = file.readAsLinesSync();
  
  // Find where `}).toList(),` is in MY CLIENTS.
  int startIndex = -1;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains("Text('") && lines[i].contains(" / session',")) {
      // The line after this is `                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: SageColors.primary)),`
      // The line after that is `                      ],`
      // The line after that is `                    ),`
      // The line after that is `                  );`
      // The line after that is `                }).toList(),`
      startIndex = i + 5;
      break;
    }
  }
  
  int endIndex = -1;
  for (int i = startIndex + 1; i < lines.length; i++) {
    if (lines[i].contains('Widget _buildSessionApprovalCard(BuildContext context, AppState state, Task t) {')) {
      endIndex = i;
      break;
    }
  }
  
  if (startIndex != -1 && endIndex != -1) {
    final newLines = <String>[];
    for (int i = 0; i <= startIndex; i++) {
      newLines.add(lines[i]);
    }
    
    // Add the proper closing for TerminalPanel MY CLIENTS
    newLines.add('              );');
    newLines.add('            },');
    newLines.add('          ),');
    newLines.add('        ),');
    newLines.add('      ],');
    newLines.add('    );');
    newLines.add('  }');
    newLines.add('');
    
    for (int i = endIndex; i < lines.length; i++) {
      newLines.add(lines[i]);
    }
    
    file.writeAsStringSync(newLines.join('\n'));
    print('Successfully fixed videographer dashboard by line index!');
  } else {
    print('Could not find start/end bounds! start=\$startIndex, end=\$endIndex');
  }
}
