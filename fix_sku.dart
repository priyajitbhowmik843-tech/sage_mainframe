import 'dart:io';

void main() {
  final files = ['lib/screens/ceo_dashboard.dart', 'lib/screens/cofounder_dashboard.dart'];

  for (final path in files) {
    final file = File(path);
    var content = file.readAsStringSync();
    
    int startIdx = content.indexOf("if (c.serviceType.toLowerCase().contains('commerce') && c.ecomPaymentType == 'Per SKU') ...[");
    if (startIdx != -1) {
      // Find the second instance of the if block since the first one is inside _showMonthlyPaymentDialog
      startIdx = content.indexOf("if (c.serviceType.toLowerCase().contains('commerce') && c.ecomPaymentType == 'Per SKU') ...[", startIdx + 1);
      
      if (startIdx != -1) {
        // Now find the start of the line where startIdx is located
        while (startIdx > 0 && (content[startIdx - 1] == ' ' || content[startIdx - 1] == '\t')) {
          startIdx--;
        }

        int endIdx = content.indexOf("const Divider(color: Colors.black26),", startIdx);
        if (endIdx != -1) {
          while (endIdx > 0 && (content[endIdx - 1] == ' ' || content[endIdx - 1] == '\t')) {
            endIdx--;
          }
          
          String badBlock = content.substring(startIdx, endIdx);
          
          String cleanBlock = r'''
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
                              
                              bool isBeforeContract = (currentYear < c.contractDate.year) || (currentYear == c.contractDate.year && month < c.contractDate.month);
                              Color bgColor = Colors.grey.shade200;
                              if (!isBeforeContract) {
                                if (totalSkus > 0) {
                                  bgColor = const Color(0xFFC8E6C9); // Pastel Green
                                } else if (month <= DateTime.now().month || currentYear < DateTime.now().year) {
                                  bgColor = const Color(0xFFFFCDD2); // Pastel Red
                                }
                              }
                              
                              return InkWell(
                                onTap: isBeforeContract ? null : () => _showSkuLogDetails(context, c, month, currentYear),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.black12)
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(monthNames[i], style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isBeforeContract ? Colors.black38 : Colors.black87)),
                                      if (totalSkus > 0)
                                        Text("₹${totalForMonth.toStringAsFixed(0)}", style: const TextStyle(fontSize: 8, color: Colors.black54, fontWeight: FontWeight.bold)),
                                      if (totalSkus > 0)
                                        Text("$totalSkus items", style: const TextStyle(fontSize: 7, color: Colors.black54)),
                                    ],
                                  ),
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
          content = content.replaceFirst(badBlock, cleanBlock);
          file.writeAsStringSync(content);
          print("Fixed SKU Tracker in $path");
        }
      }
    }
  }
}
