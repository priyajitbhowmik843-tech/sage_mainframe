import 'dart:io';

void main() {
  final file = File('lib/screens/videographer_dashboard.dart');
  String content = file.readAsStringSync();
  
  // 1. Delete lines 546 to 695
  final lines = content.split('\n');
  final newLines = <String>[];
  
  for (int i = 0; i < lines.length; i++) {
    // lines are 0-indexed. Line 546 is index 545. Line 695 is index 694.
    if (i >= 545 && i <= 694) {
      continue;
    }
    newLines.add(lines[i]);
  }
  
  content = newLines.join('\n');
  
  // 2. Fix the end of _buildHomeTab
  final brokenEnd = '''                          if (t.isCompleted && client != null)
                            Text('Rate: \\u20B9\${client?.sessionRate.toStringAsFixed(0) ?? 0}', style: TextStyle(fontSize: 11, color: SageColors.primary, fontWeight: FontWeight.bold)),              );
            },
          ),
        ),
      ],
    );
  }''';
  
  final fixedEnd = '''                          if (t.isCompleted && client != null)
                            Text('Rate: \\u20B9\${client?.sessionRate.toStringAsFixed(0) ?? 0}', style: TextStyle(fontSize: 11, color: SageColors.primary, fontWeight: FontWeight.bold)),
                          Text(statusText, style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                    Icon(t.isCompleted ? Icons.check_circle : t.isApprovedByVideographer ? Icons.videocam : Icons.hourglass_top,
                        color: statusColor, size: 20),
                  ],
                ),
                if (!t.isCompleted && !t.isSubmitted && !t.isPostponeRequested && t.isApprovedByVideographer) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          side: const BorderSide(color: Colors.black),
                        ),
                        onPressed: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: t.deadline,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selected != null) {
                            context.read<AppState>().requestPostponeTask(t.id, selected);
                          }
                        },
                        child: const Text('POSTPONE'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SageColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => context.read<AppState>().submitTask(t.id),
                        child: const Text('COMPLETE'),
                      ),
                    ],
                  )
                ]
              ],
            ),
          );
        }).toList(),
      ),
    );
  }''';
  
  if (content.contains(brokenEnd)) {
    content = content.replaceFirst(brokenEnd, fixedEnd);
    print("Fixed _buildHomeTab!");
  } else {
    // Try relaxing newline characters
    final regexBrokenEnd = RegExp(brokenEnd.replaceAll('\\', '\\\\').replaceAll('\$', '\\\$').replaceAll('(', '\\(').replaceAll(')', '\\)').replaceAll('[', '\\[').replaceAll(']', '\\]').replaceAll('?', '\\?').replaceAll('\n', '\\r?\\n'));
    if (regexBrokenEnd.hasMatch(content)) {
      content = content.replaceFirst(regexBrokenEnd, fixedEnd);
      print("Fixed _buildHomeTab with Regex!");
    } else {
      print("Could not find broken end of _buildHomeTab.");
    }
  }
  
  file.writeAsStringSync(content);
  print("File updated.");
}
