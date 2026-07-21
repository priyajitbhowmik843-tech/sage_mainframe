import "dart:io";

void main() {
  void updateFile(String path) {
    var file = File(path);
    var content = file.readAsStringSync();

    // 1. We want to find the exact block and replace it
    // First, let us remove the discount line: _buildClientDetailRow("Discount", "\${c.discountPercent}%"),
    content = content.replaceAll(
      '_buildClientDetailRow("Discount", "\${c.discountPercent}%"),',
      '',
    );

    // Now replace the Monthly Fee part. We need to handle both CFO and CEO dashboards.
    // In CEO Dashboard, it looks like:
    String ceoMonthlyFeePattern =
        """                    c.ecomPaymentType == 'Per SKU'
                        ? _buildClientDetailRow(
                            "Base Monthly Fee",
                            "?\${c.getPayableForMonth(DateTime.now().month, DateTime.now().year).toStringAsFixed(0)} (Actual varies by SKU logs)",
                          )
                        : _buildClientDetailRow(
                            "Monthly Fee",
                            "?\${c.monthlyPayable.toStringAsFixed(0)}",
                          ),""";

    String newCeoMonthlyFee =
        """                    if (c.isWebsiteHandlingActive)
                      _buildClientDetailRow(
                        "Website Handling",
                        "?\${c.websiteHandlingFee.toStringAsFixed(0)}",
                      ),
                    c.ecomPaymentType == 'Per SKU'
                        ? _buildClientDetailRow(
                            "Base Monthly Fee",
                            "?\${c.getPayableForMonth(DateTime.now().month, DateTime.now().year).toStringAsFixed(0)} (Actual varies by SKU logs)",
                          )
                        : _buildClientDetailRow(
                            "Monthly Fee",
                            "?\${(c.monthlyPayable + (c.isWebsiteHandlingActive ? c.websiteHandlingFee : 0)).toStringAsFixed(0)}",
                          ),""";

    if (content.contains(ceoMonthlyFeePattern)) {
      content = content.replaceAll(ceoMonthlyFeePattern, newCeoMonthlyFee);
    } else {
      // In CFO Dashboard, it's one line:
      String cfoMonthlyFeePattern =
          """                    c.ecomPaymentType == 'Per SKU' ? _buildClientDetailRow("Base Monthly Fee", "?\${c.getPayableForMonth(DateTime.now().month, DateTime.now().year).toStringAsFixed(0)} (Actual varies by SKU logs)") : _buildClientDetailRow("Monthly Fee", "?\${c.monthlyPayable.toStringAsFixed(0)}"),""";

      String newCfoMonthlyFee =
          """                    if (c.isWebsiteHandlingActive) _buildClientDetailRow("Website Handling", "?\${c.websiteHandlingFee.toStringAsFixed(0)}"),
                    c.ecomPaymentType == 'Per SKU' ? _buildClientDetailRow("Base Monthly Fee", "?\${c.getPayableForMonth(DateTime.now().month, DateTime.now().year).toStringAsFixed(0)} (Actual varies by SKU logs)") : _buildClientDetailRow("Monthly Fee", "?\${(c.monthlyPayable + (c.isWebsiteHandlingActive ? c.websiteHandlingFee : 0)).toStringAsFixed(0)}"),""";

      content = content.replaceAll(cfoMonthlyFeePattern, newCfoMonthlyFee);
    }

    file.writeAsStringSync(content);
    print("Updated " + path);
  }

  updateFile("lib/screens/ceo_dashboard.dart");
  updateFile("lib/screens/cofounder_dashboard.dart");
}
