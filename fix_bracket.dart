import 'dart:io';

void main() {
  final files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cofounder_dashboard.dart',
  ];

  for (final path in files) {
    final file = File(path);
    var content = file.readAsStringSync();

    // 1. Fix _showSkuLogDetails DataTable closing bracket
    String oldEnd1 = r'''
                      ]);
                    }).toList(),
                  ),
                ),
              ),
              actions: [
''';
    String newEnd1 = r'''
                      ]);
                    }).toList(),
                  ),
                ),
                ),
              ),
              actions: [
''';

    // Actually, it's safer to just find the `}).toList(), \n ),` and replace it with `}).toList(), \n ), \n ),` for both tables.
    // Wait, the first one ends with:
    // } ).toList(),
    // ),
    // ),
    // ),
    // actions: [

    // Let's do a more robust replacement using RegExp or specific blocks.

    // Let's first undo the previous broken replacement, then re-apply it correctly.
    // To undo, we change `SingleChildScrollView( \n scrollDirection: Axis.horizontal, \n child: DataTable(` back to `DataTable(`.
    // Wait, let's just find the `}).toList(),` block for both.

    String oldBlock1 = r'''
                      ]);
                    }).toList(),
                  ),
                ),
              ),
              actions: [
''';
    String newBlock1 = r'''
                      ]);
                    }).toList(),
                  ),
                  ),
                ),
              ),
              actions: [
''';
    content = content.replaceAll(oldBlock1, newBlock1);

    String oldBlock2 = r'''
                      ]);
                    }).toList(),
                  ),
                ),
              ),
              actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CLOSE", style: TextStyle(color: Colors.black54))),
''';
    String newBlock2 = r'''
                      ]);
                    }).toList(),
                  ),
                  ),
                ),
              ),
              actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CLOSE", style: TextStyle(color: Colors.black54))),
''';
    content = content.replaceAll(oldBlock2, newBlock2);

    file.writeAsStringSync(content);
    print("Fixed missing closing bracket in $path");
  }
}
