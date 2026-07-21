import 'dart:io';

void main() {
  final files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cofounder_dashboard.dart',
  ];

  for (final path in files) {
    final file = File(path);
    var content = file.readAsStringSync();

    // 1. Add SKU Tracker Grid
    String skuTrackerCode = r'''
                          const SizedBox(height: 10),
                          const Text("2026 SKU Tracker", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
                          const SizedBox(height: 8),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                              childAspectRatio: 1.5,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6,
                            ),
                            itemCount: 12,
                            itemBuilder: (context, i) {
                              final month = i + 1;
                              final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                              final currentYear = DateTime.now().year;
                              double totalForMonth = c.getPayableForMonth(month, currentYear);
                              int totalSkus = 0;
                              for (var log in c.ecomSkuLogs) {
                                if (log.timestamp.month == month && log.timestamp.year == currentYear) {
                                  totalSkus += log.sku + log.duplicate + log.catalogue;
                                }
                              }
                              
                              return Container(
                                decoration: BoxDecoration(
                                  color: totalSkus > 0 ? const Color(0xFFBBDEFB) : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.black12)
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(monthNames[i], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87)),
                                    if (totalSkus > 0)
                                      Text("₹${totalForMonth.toStringAsFixed(0)}", style: const TextStyle(fontSize: 8, color: Colors.black54, fontWeight: FontWeight.bold)),
                                    if (totalSkus > 0)
                                      Text("$totalSkus items", style: const TextStyle(fontSize: 7, color: Colors.black54)),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
''';

    content = content.replaceAll(
      '                          const SizedBox(height: 10),\n                          Row(\n                            children: [\n                              ElevatedButton(\n                                onPressed: () => _showSkuLogDialog(context, c),\n                                style: ElevatedButton.styleFrom(\n                                  backgroundColor: const Color(0xFF0D0E0E),\n                                  foregroundColor: Colors.white,\n                                ),\n                                child: const Text("Log Daily SKUs"),\n                              ),\n                            ],\n                          ),\n                          const SizedBox(height: 10),',
      '$skuTrackerCode                          Row(\n                            children: [\n                              ElevatedButton(\n                                onPressed: () => _showSkuLogDialog(context, c),\n                                style: ElevatedButton.styleFrom(\n                                  backgroundColor: const Color(0xFF0D0E0E),\n                                  foregroundColor: Colors.white,\n                                ),\n                                child: const Text("Log Daily SKUs"),\n                              ),\n                            ],\n                          ),\n                          const SizedBox(height: 10),',
    );

    // 2. Fix the state dropdown logic to initialize local values based on a clean casing
    content = content.replaceAll(
      'String localServiceType = \'Marketing\';',
      'String localServiceType = c.serviceType.toLowerCase().contains(\'commerce\') ? \'E-Commerce\' : c.serviceType;',
    );
    content = content.replaceAll(
      'String serviceType = c.serviceType;',
      'String serviceType = c.serviceType.toLowerCase().contains(\'commerce\') ? \'E-Commerce\' : c.serviceType;',
    );

    file.writeAsStringSync(content);
    print("Updated $path");
  }

  // 3. Fix Client model to forcefully capitalize E-Commerce upon loading
  final modelFile = File('lib/models/models.dart');
  var modelContent = modelFile.readAsStringSync();
  modelContent = modelContent.replaceAll(
    'serviceType: data[\'serviceType\'] ?? \'Marketing\',',
    'serviceType: (data[\'serviceType\'] ?? \'Marketing\').toString().toLowerCase() == \'e-commerce\' ? \'E-Commerce\' : (data[\'serviceType\'] ?? \'Marketing\'),',
  );
  modelFile.writeAsStringSync(modelContent);
  print("Updated models.dart");
}
