import 'dart:io';

void main() {
  final files = ['lib/screens/ceo_dashboard.dart', 'lib/screens/cofounder_dashboard.dart'];

  String skuTrackerCode = r'''
                      if (c.serviceType.toLowerCase().contains('commerce') && c.ecomPaymentType == 'Per SKU') ...[
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
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => _showSkuLogDialog(context, c),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D0E0E),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Log Daily SKUs"),
                            ),
                          ],
                        ),
                      ],
''';

  for (final path in files) {
    final file = File(path);
    var content = file.readAsStringSync();
    
    // Find the exact line using regex: spaces + const Divider(color: Colors.black26), + spaces + if (c.postRequirements.isNotEmpty
    RegExp regExp = RegExp(r"([ \t]+const Divider\(color: Colors\.black26\),[\r\n \t]+if \(c\.postRequirements\.isNotEmpty)");
    
    if (!content.contains('2026 SKU Tracker')) {
      final match = regExp.firstMatch(content);
      if (match != null) {
        String exactMatch = match.group(1)!;
        content = content.replaceFirst(exactMatch, skuTrackerCode + exactMatch);
        file.writeAsStringSync(content);
        print("Updated \$path");
      } else {
        print("Target not found in \$path");
      }
    } else {
      print("Already updated \$path");
    }
  }
}
