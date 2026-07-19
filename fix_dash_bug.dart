import 'dart:io';

void replaceInFile(String path) {
  final file = File(path);
  var content = file.readAsStringSync();
  
  // Fix Main Pool Balance text and add LEDGER button
  final badMainPoolText = 'Text("₹", style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black)),';
  final goodMainPoolRow = '''
                        Text("₹\${state.mainPool.netBalance.toStringAsFixed(0)}", style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black)),
                        Row(
                          children: [
                            const Text("MAIN POOL BALANCE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                            const SizedBox(width: 6),
                            AnimatedRotation(turns: _showMainPoolShares ? 0.5 : 0, duration: const Duration(milliseconds: 300), child: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54)),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _showAddLedgerDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCE93D8),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.black, width: 1.5)),
                      ),
                      child: const Text("+ LEDGER", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
''';

  // We need to replace the old Main Pool text and its following Row, up to the end of the `children:` list inside the `Row(mainAxisAlignment: MainAxisAlignment.spaceBetween`
  
  // It's safer to just do string replacements on the specific lines:
  content = content.replaceFirst('Text("₹", style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black)),', 'Text("₹\${state.mainPool.netBalance.toStringAsFixed(0)}", style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black)),');
  
  // There are two 'Text("₹"'s. The second one is for Video pool.
  content = content.replaceFirst('Text("₹", style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black)),', 'Text("₹\${state.videoPool.netBalance.toStringAsFixed(0)}", style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black)),');

  // Now inject the buttons.
  final mainPoolFind = '''
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
''';
  final mainPoolReplace = '''
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _showAddLedgerDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B9DC3), // matches typical sage tertiary/primary
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.black, width: 1.5)),
                      ),
                      child: const Text("+ LEDGER", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
''';

  content = content.replaceFirst(mainPoolFind, mainPoolReplace);
  
  // same for Video pool
  content = content.replaceFirst(mainPoolFind, mainPoolReplace); // because the snippet is identical for the video pool

  file.writeAsStringSync(content);
  print('\$path fixed');
}

void main() {
  replaceInFile('lib/screens/ceo_dashboard.dart');
  replaceInFile('lib/screens/cofounder_dashboard.dart');
}
