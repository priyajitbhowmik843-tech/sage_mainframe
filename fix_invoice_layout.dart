import "dart:io";

void main() {
  final file = File("lib/services/invoice_service.dart");
  String content = file.readAsStringSync();

  String oldBottomArea = """                  // Bottom Area
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      // Left T&C
                      pw.Expanded(
                        flex: 6,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              "TERM AND CONDITIONS",
                              style: pw.TextStyle(
                                color: _darkText,
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              "By subscribing, the client agrees to the services, non-refundable payment, and confidentiality terms. Market Sages is not liable for guaranteed results.",
                              style: pw.TextStyle(
                                color: _darkText,
                                fontSize: 9,
                              ),
                            ),
                            pw.SizedBox(height: 30),
                            pw.Text(
                              "THANK YOU FOR YOUR BUSINESS",
                              style: pw.TextStyle(
                                color: _darkText,
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 40),
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  "Priyajit Bhowmik",
                                  style: pw.TextStyle(
                                    color: _greyText,
                                    fontSize: 16,
                                    fontStyle: pw.FontStyle.italic,
                                  ),
                                ),
                                pw.SizedBox(height: 2),
                                pw.Container(
                                  width: 120,
                                  height: 1,
                                  color: _darkText,
                                ),
                                pw.SizedBox(height: 5),
                                pw.Text(
                                  "Priyajit Bhowmik\nCEO, Market Sages",
                                  style: pw.TextStyle(
                                    color: _darkText,
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      pw.SizedBox(width: 40),

                      // Right Totals & Signature
                      pw.Expanded(
                        flex: 4,
                        child: pw.Builder(
                          builder: (context) {
                            double baseAmount = client.getPayableForMonth(
                              month.month,
                              month.year,
                            );
                            double discountAmount =
                                client.monthlyDiscounts[month.month
                                    .toString()] ??
                                0;
                            double addOnsTotal = selectedAddOns.fold(
                              0,
                              (sum, a) => sum + a.amount,
                            );
                            double grandTotal =
                                baseAmount + addOnsTotal - discountAmount;

                            return pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(
                                      "Base Monthly Fee:",
                                      style: pw.TextStyle(
                                        color: _darkText,
                                        fontSize: 11,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    pw.Text(
                                      "\u20B9 ${baseAmount.toStringAsFixed(0)}",
                                      style: pw.TextStyle(
                                        color: _darkText,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                if (addOnsTotal > 0) ...[
                                  pw.SizedBox(height: 8),
                                  pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(
                                        "Add-Ons Total:",
                                        style: pw.TextStyle(
                                          color: _darkText,
                                          fontSize: 11,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                      ),
                                      pw.Text(
                                        "\u20B9 ${addOnsTotal.toStringAsFixed(0)}",
                                        style: pw.TextStyle(
                                          color: _darkText,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (discountAmount > 0) ...[
                                  pw.SizedBox(height: 8),
                                  pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(
                                        "Discount:",
                                        style: pw.TextStyle(
                                          color: _darkText,
                                          fontSize: 11,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                      ),
                                      pw.Text(
                                        "- \u20B9 ${discountAmount.toStringAsFixed(0)}",
                                        style: pw.TextStyle(
                                          color: PdfColors.red,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                pw.SizedBox(height: 10),
                                pw.Container(
                                  width: double.infinity,
                                  color: _tealColor,
                                  padding: const pw.EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  child: pw.Row(
                                    mainAxisAlignment:
                                        pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(
                                        "Total Amount:",
                                        style: pw.TextStyle(
                                          color: PdfColors.white,
                                          fontSize: 12,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                      ),
                                      pw.Text(
                                        "\u20B9 ${grandTotal.toStringAsFixed(0)}",
                                        style: pw.TextStyle(
                                          color: PdfColors.white,
                                          fontSize: 12,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),""";

  String newBottomArea = """                  // Bottom Area
                  pw.Builder(
                    builder: (context) {
                      double baseAmount = client.monthlyPayable;
                      double discountAmount = client.monthlyDiscounts[month.month.toString()] ?? 0;
                      double addOnsTotal = selectedAddOns.fold(0, (sum, a) => sum + a.amount);
                      double websiteHandlingFee = client.isWebsiteHandlingActive ? client.websiteHandlingFee : 0;
                      double grandTotal = baseAmount + websiteHandlingFee + addOnsTotal - discountAmount;
                      
                      if (client.ecomPaymentType == 'Per SKU') {
                        grandTotal = client.getPayableForMonth(month.month, month.year) + addOnsTotal - discountAmount;
                        baseAmount = grandTotal - addOnsTotal + discountAmount;
                      }

                      return pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          // Left T&C
                          pw.Expanded(
                            flex: 6,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  "TERM AND CONDITIONS",
                                  style: pw.TextStyle(color: _darkText, fontSize: 10, fontWeight: pw.FontWeight.bold),
                                ),
                                pw.SizedBox(height: 8),
                                pw.Text(
                                  "By subscribing, the client agrees to the services, non-refundable payment, and confidentiality terms. Market Sages is not liable for guaranteed results.",
                                  style: pw.TextStyle(color: _darkText, fontSize: 9),
                                ),
                                pw.SizedBox(height: 30),
                                pw.Text(
                                  "THANK YOU FOR YOUR BUSINESS",
                                  style: pw.TextStyle(color: _darkText, fontSize: 11, fontWeight: pw.FontWeight.bold),
                                ),
                                pw.SizedBox(height: 40),
                                pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      "Priyajit Bhowmik",
                                      style: pw.TextStyle(color: _greyText, fontSize: 16, fontStyle: pw.FontStyle.italic),
                                    ),
                                    pw.SizedBox(height: 2),
                                    pw.Container(width: 120, height: 1, color: _darkText),
                                    pw.SizedBox(height: 5),
                                    pw.Text(
                                      "Priyajit Bhowmik\nCEO, Market Sages",
                                      style: pw.TextStyle(color: _darkText, fontSize: 10, fontWeight: pw.FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          pw.SizedBox(width: 40),

                          // Right Totals & Signature
                          pw.Expanded(
                            flex: 4,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Row(
                                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Text(client.ecomPaymentType == 'Per SKU' ? "Base Monthly Fee:" : "Base Package Fee:", style: pw.TextStyle(color: _darkText, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                                    pw.Text("\u20B9 ${baseAmount.toStringAsFixed(0)}", style: pw.TextStyle(color: _darkText, fontSize: 11)),
                                  ],
                                ),
                                if (client.isWebsiteHandlingActive && client.ecomPaymentType != 'Per SKU') ...[
                                  pw.SizedBox(height: 8),
                                  pw.Row(
                                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text("Website Handling:", style: pw.TextStyle(color: _darkText, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                                      pw.Text("\u20B9 ${websiteHandlingFee.toStringAsFixed(0)}", style: pw.TextStyle(color: _darkText, fontSize: 11)),
                                    ],
                                  ),
                                ],
                                if (addOnsTotal > 0) ...[
                                  pw.SizedBox(height: 8),
                                  pw.Row(
                                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text("Add-Ons Total:", style: pw.TextStyle(color: _darkText, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                                      pw.Text("\u20B9 ${addOnsTotal.toStringAsFixed(0)}", style: pw.TextStyle(color: _darkText, fontSize: 11)),
                                    ],
                                  ),
                                ],
                                if (discountAmount > 0) ...[
                                  pw.SizedBox(height: 8),
                                  pw.Row(
                                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text("Discount:", style: pw.TextStyle(color: _darkText, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                                      pw.Text("- \u20B9 ${discountAmount.toStringAsFixed(0)}", style: pw.TextStyle(color: PdfColors.red, fontSize: 11)),
                                    ],
                                  ),
                                ],
                                pw.SizedBox(height: 10),
                                pw.Container(
                                  width: double.infinity,
                                  color: _tealColor,
                                  padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                  child: pw.Row(
                                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text("Total Amount:", style: pw.TextStyle(color: PdfColors.white, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                                      pw.Text("\u20B9 ${grandTotal.toStringAsFixed(0)}", style: pw.TextStyle(color: PdfColors.white, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                  ),""";

  if (content.contains(oldBottomArea)) {
    content = content.replaceAll(oldBottomArea, newBottomArea);
    file.writeAsStringSync(content);
    print("Replaced Bottom Area Successfully");
  } else {
    print("Could not find the target string!");
  }
}
