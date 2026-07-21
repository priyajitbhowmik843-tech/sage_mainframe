import 'dart:io';

void main() {
  final file = File('lib/screens/ceo_dashboard.dart');
  var content = file.readAsStringSync();

  // Add state variables
  if (!content.contains('bool _showMainPoolShares = false;')) {
    content = content.replaceFirst(
      'bool _showDetailedShares = false;',
      'bool _showMainPoolShares = false;\n  bool _showVideoPoolShares = false;',
    );
  }

  // Define the new UI
  final newUi = '''
        // --- Main Pool Balance ---
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _showMainPoolShares = !_showMainPoolShares),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _showMainPoolShares ? const Color(0xFFF5F0E6) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹\",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: -1,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FinanceLedgerScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SageColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.black, width: 1.5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        "LEDGER",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      "MAIN POOL BALANCE",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: _showMainPoolShares ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _showMainPoolShares ? Colors.white12 : SageColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _showMainPoolShares ? Colors.white24 : Colors.black,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: (state.mainPool.income > 0 ? (state.mainPool.netBalance / state.mainPool.income).clamp(0.0, 1.0) : 0.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: SageColors.tertiary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _showMainPoolShares ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Builder(
                    builder: (context) {
                      final shares = state.mainPool.shares;
                      final ritam = shares['ritam'] ?? 0.0;
                      final priyajit = shares['priyajit'] ?? 0.0;
                      final mktEx = shares['marketingEx'] ?? 0.0;
                      final total = ritam + priyajit + mktEx;
                      Widget shareRow(String name, double amount, Color color, IconData icon) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                        child: Icon(icon, color: color, size: 14),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                                    ],
                                  ),
                                  Text("₹\", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 6,
                                width: double.infinity,
                                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(4)),
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: total > 0 ? (amount / total).clamp(0.0, 1.0) : 0.0,
                                  child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Divider(color: Colors.black12),
                          const Text("PROFIT SHARE BREAKDOWN", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.5)),
                          shareRow("Ritam Ghosh", ritam, const Color(0xFF00796B), Icons.person),
                          shareRow("Priyajit Bhowmik", priyajit, Colors.blue, Icons.person),
                          if (mktEx > 0) shareRow("Marketing Executive", mktEx, const Color(0xFFCE93D8), Icons.campaign),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // --- Video Production Pool Balance ---
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _showVideoPoolShares = !_showVideoPoolShares),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _showVideoPoolShares ? const Color(0xFFF5F0E6) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹\",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: -1,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FinanceLedgerScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCE93D8),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.black, width: 1.5),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      icon: const Icon(Icons.videocam, size: 16),
                      label: const Text(
                        "VIDEO",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      "VIDEO PRODUCTION POOL",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: _showVideoPoolShares ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _showVideoPoolShares ? Colors.white12 : SageColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _showVideoPoolShares ? Colors.white24 : Colors.black,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: (state.videoPool.income > 0 ? (state.videoPool.netBalance / state.videoPool.income).clamp(0.0, 1.0) : 0.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: SageColors.tertiary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _showVideoPoolShares ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Builder(
                    builder: (context) {
                      final shares = state.videoPool.shares;
                      final ritam = shares['ritam'] ?? 0.0;
                      final priyajit = shares['priyajit'] ?? 0.0;
                      final total = ritam + priyajit;
                      Widget shareRow(String name, double amount, Color color, IconData icon) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                        child: Icon(icon, color: color, size: 14),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                                    ],
                                  ),
                                  Text("₹\", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 6,
                                width: double.infinity,
                                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(4)),
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: total > 0 ? (amount / total).clamp(0.0, 1.0) : 0.0,
                                  child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Divider(color: Colors.black12),
                          const Text("PROFIT SHARE BREAKDOWN", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1.5)),
                          shareRow("Ritam Ghosh", ritam, const Color(0xFF00796B), Icons.person),
                          shareRow("Priyajit Bhowmik", priyajit, Colors.blue, Icons.person),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),''';

  // We need to replace from // --- Total Net Running Balance --- up to the next const SizedBox(height: 14), before // Income / Expenses Stat Grid
  final startIndex = content.indexOf('// --- Total Net Running Balance ---');
  final endIndex = content.indexOf('// Income / Expenses Stat Grid');

  if (startIndex != -1 && endIndex != -1) {
    final toReplace = content.substring(startIndex, endIndex);
    content = content.replaceFirst(toReplace, newUi + '\n        ');
    file.writeAsStringSync(content);
    print("CEO dashboard updated successfully");
  } else {
    print("Could not find replacement boundaries in CEO dashboard.");
  }
}
