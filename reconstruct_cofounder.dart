import 'dart:io';

void main() {
  final file = File('lib/screens/cofounder_dashboard.dart');
  final lines = file.readAsLinesSync();

  final out = <String>[];
  bool injected = false;

  for (int i = 0; i < lines.length; i++) {
    out.add(lines[i]);
    if (lines[i].contains('valueColor: SageColors.secondary,') &&
        !injected &&
        i > 2900 &&
        i < 3100) {
      out.add(r'''
                icon: Icons.trending_down,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 6-Month Income Chart
        Builder(
          builder: (context) {
            final now = DateTime.now();
            final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            List<String> labels = [];
            List<double> values = [];
            List<bool> editable = [];
            List<String> keys = [];
            
            for (int i = 5; i >= 0; i--) {
              int m = now.month - i;
              int y = now.year;
              if (m <= 0) {
                m += 12;
                y -= 1;
              }
              labels.add(monthNames[m - 1]);
              String key = '$y-${m.toString().padLeft(2, '0')}';
              keys.add(key);
              values.add(state.netRunningBalance[key] ?? 0.0);
              editable.add(y < 2026 || (y == 2026 && m <= 6));
            }
            
            double maxVal = values.isEmpty ? 1000 : values.reduce((a, b) => a > b ? a : b);
            if (maxVal == 0) maxVal = 1000;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("6-MONTH NET RUNNING BALANCE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: SageColors.onSurfaceVariant)),
                const SizedBox(height: 10),
                IncomeComboChart(
                  values: values,
                  labels: labels,
                  barColor: SageColors.tertiaryContainer,
                  maxValue: maxVal,
                  editable: editable,
                  onEdit: (index) {
                    final key = keys[index];
                    final currentVal = values[index];
                    final TextEditingController _ctrl = TextEditingController(text: currentVal.toStringAsFixed(0));
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Edit Net Running Balance for ${labels[index]}'),
                        content: TextField(
                          controller: _ctrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Amount (\u20B9)'),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
                          ElevatedButton(
                            onPressed: () {
                              final val = double.tryParse(_ctrl.text);
                              if (val != null) {
                                state.updateNetRunningBalance(key, val);
                              }
                              Navigator.pop(ctx);
                            },
                            child: const Text('SAVE'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
''');
      injected = true;
    }
  }

  file.writeAsStringSync(out.join('\n'));
  print('done');
}
