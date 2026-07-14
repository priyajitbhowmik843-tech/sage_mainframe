const fs = require('fs');
const path = require('path');

const OLD_BALANCE_CARD = `        // Main balance box with purple visual
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(3, 3),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "₹\${state.netBalance.toStringAsFixed(0)}",
                        style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const Text(
                        "TOTAL NET RUNNING BALANCE",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: SageColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => _showCFFinanceForm = !_showCFFinanceForm),
                    style: ElevatedButton.styleFrom(backgroundColor: SageColors.tertiary),
                    child: Text(_showCFFinanceForm ? "CANCEL" : "+ LEDGER"),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Segmented Purple progress bar
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: SageColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: (state.totalIncome > 0
                      ? (state.netBalance / state.totalIncome).clamp(0.0, 1.0)
                      : 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: SageColors.tertiary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),`;

const NEW_BALANCE_CARD = `        // Main balance box - tappable accordion
        GestureDetector(
          onTap: () => setState(() => _showDetailedShares = !_showDetailedShares),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _showDetailedShares ? const Color(0xFF1A1A2E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(3, 3),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "₹\${state.netBalance.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: _showDetailedShares ? Colors.white : Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "TOTAL NET RUNNING BALANCE",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _showDetailedShares ? Colors.white60 : SageColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 6),
                            AnimatedRotation(
                              turns: _showDetailedShares ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                size: 16,
                                color: _showDetailedShares ? Colors.white60 : SageColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => _showCFFinanceForm = !_showCFFinanceForm),
                      style: ElevatedButton.styleFrom(backgroundColor: SageColors.tertiary),
                      child: Text(_showCFFinanceForm ? "CANCEL" : "+ LEDGER"),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Segmented Purple progress bar
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _showDetailedShares ? Colors.white12 : SageColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _showDetailedShares ? Colors.white24 : Colors.black, width: 1.5),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: (state.totalIncome > 0
                        ? (state.netBalance / state.totalIncome).clamp(0.0, 1.0)
                        : 0.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: SageColors.tertiary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                // ── Profit share accordion ──
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _showDetailedShares
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Builder(
                    builder: (context) {
                      final shares = state.profitShares;
                      final ritam = shares['ritam'] ?? 0.0;
                      final priyajit = shares['priyajit'] ?? 0.0;
                      final mktEx = shares['marketingEx'] ?? 0.0;
                      final total = ritam + priyajit + mktEx;
                      Widget shareRow(String name, double amount, Color color, IconData icon) {
                        final pct = total > 0 ? (amount / total * 100) : 0.0;
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
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(icon, color: color, size: 14),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("₹\${amount.toStringAsFixed(0)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
                                      Text("\${pct.toStringAsFixed(1)}%", style: TextStyle(fontSize: 10, color: Colors.white54)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 6,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                alignment: Alignment.centerLeft,
                                child: FractionallySizedBox(
                                  widthFactor: total > 0 ? (amount / total).clamp(0.0, 1.0) : 0.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
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
                          const Divider(color: Colors.white24),
                          const Text("PROFIT SHARE BREAKDOWN", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1.5)),
                          shareRow("Ritam Ghosh", ritam, const Color(0xFF80CBC4), Icons.person),
                          shareRow("Priyajit Bhowmik", priyajit, const Color(0xFFFFD54F), Icons.person),
                          if (mktEx > 0) shareRow("Marketing Executive", mktEx, const Color(0xFFCE93D8), Icons.campaign),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),`;

function patch(filepath) {
    let content = fs.readFileSync(filepath, 'utf8');
    
    // Normalize line endings to LF for matching
    const normalizedContent = content.replace(/\r\n/g, '\n');
    const normalizedOld = OLD_BALANCE_CARD.replace(/\r\n/g, '\n');
    
    if (!normalizedContent.includes(normalizedOld)) {
        console.log(`WARNING: Could not find target block in ${filepath}`);
        console.log("Trying to find partial match...");
        const idx = normalizedContent.indexOf('// Main balance box with purple visual');
        console.log(`Found header at index: ${idx}`);
        return;
    }
    
    const patched = normalizedContent.replace(normalizedOld, NEW_BALANCE_CARD.replace(/\r\n/g, '\n'));
    fs.writeFileSync(filepath, patched, 'utf8');
    console.log(`Patched: ${filepath}`);
}

const base = path.join(__dirname, 'lib', 'screens');
patch(path.join(base, 'ceo_dashboard.dart'));
