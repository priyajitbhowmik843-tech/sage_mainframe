import "dart:io";

void main() {
  final file = File("lib/services/invoice_service.dart");
  String content = file.readAsStringSync();

  // 1. Replace Top "Total Amount" and "SERVICES INCLUDED" block with the new layout
  String oldTopSection = """                  pw.SizedBox(height: 5),
                  pw.Text(
                    "Total Amount: \\u20B9 \${client.getPayableForMonth(month.month, month.year).toStringAsFixed(0)}",
                    style: pw.TextStyle(
                      color: _darkText,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),

                  pw.SizedBox(height: 10),
                  pw.Divider(color: _greyText, thickness: 0.5),
                  pw.SizedBox(height: 20),

                  // Services Included Box
                  pw.Container(
                    color: _tealColor,
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    child: pw.Text(
                      "SERVICES INCLUDED",
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 10),

                  // Dynamic Checklist
                  ..._buildDynamicChecklist(client, month, selectedAddOns),""";

  String newTopSection = """                  pw.SizedBox(height: 10),
                  pw.Divider(color: _greyText, thickness: 0.5),
                  pw.SizedBox(height: 20),

                  // Two column layout for Deliverables and Add-Ons
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Left Column: Deliverables
                      pw.Expanded(
                        flex: 1,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              color: _tealColor,
                              padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              child: pw.Text(
                                "DELIVERABLES",
                                style: pw.TextStyle(color: PdfColors.white, fontSize: 12, fontWeight: pw.FontWeight.bold),
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            ..._buildDynamicChecklist(client, month),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 20),
                      // Right Column: Add-Ons
                      pw.Expanded(
                        flex: 1,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            if (selectedAddOns.isNotEmpty) ...[
                              pw.Container(
                                color: _tealColor,
                                padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                child: pw.Text(
                                  "ADD-ONS",
                                  style: pw.TextStyle(color: PdfColors.white, fontSize: 12, fontWeight: pw.FontWeight.bold),
                                ),
                              ),
                              pw.SizedBox(height: 10),
                              ..._buildAddOnsList(selectedAddOns),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),""";

  content = content.replaceAll(oldTopSection, newTopSection);

  // 2. Move Signature
  String oldSignature = """                                pw.SizedBox(height: 25),
                                pw.Center(
                                  child: pw.Column(
                                    children: [
                                      pw.Text(
                                        "Priyajit Bhowmik",
                                        style: pw.TextStyle(
                                          color: _greyText,
                                          fontSize: 16,
                                          fontStyle: pw.FontStyle.italic,
                                        ),
                                      ), // Signature placeholder
                                      pw.Container(
                                        width: 120,
                                        height: 1,
                                        color: _darkText,
                                      ),
                                      pw.SizedBox(height: 5),
                                      pw.Text(
                                        "Priyajit Bhowmik",
                                        style: pw.TextStyle(
                                          color: _darkText,
                                          fontSize: 10,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),""";

  content = content.replaceAll(oldSignature, ""); // Remove from right column

  String termsEnd = """                            pw.Text(
                              "THANK YOU FOR YOUR BUSINESS",
                              style: pw.TextStyle(
                                color: _darkText,
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),""";

  String newSignature = """                            pw.Text(
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
                                  "Priyajit Bhowmik\\nCEO, Market Sages",
                                  style: pw.TextStyle(
                                    color: _darkText,
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),""";

  content = content.replaceAll(termsEnd, newSignature);

  // 3. Update _buildDynamicChecklist and Add _buildAddOnsList
  String oldChecklistFunc = """  static List<pw.Widget> _buildDynamicChecklist(Client client, DateTime month, List<ClientAddOn> selectedAddOns) {
    List<String> items = [];

    items.add("Social Media Strategy (\${client.packageType} Package)");

    int totalPosts =
        (client.weeklyPosts + client.weeklyReels + client.weeklyCarousels) * 4;
    if (totalPosts > 0) {
      items.add(
        "\$totalPosts+ Posts/Month (Including \${client.weeklyReels * 4} Reels & \${client.weeklyCarousels * 4} Carousels)",
      );
    }

    if (client.weeklyStories > 0) {
      items.add("\${client.weeklyStories * 4}+ Stories/Month");
    }

    if (client.postRequirements.isNotEmpty &&
        client.postRequirements != 'TBD') {
      items.add("Requirements: \${client.postRequirements}");
    } else if (totalPosts == 0 && client.weeklyStories == 0) {
      // If absolutely no deliverables are entered, we should at least have one line so it's not empty, or maybe we leave it empty.
      // We will only use these standard tracking items:
      items.add("Captions, Hashtags & Trend Research");
      items.add("Provide Content Calendar");
      items.add("Monthly performance report");
    } else {
      items.add("Captions, Hashtags & Trend Research");
      items.add("Provide Content Calendar");
      items.add("Monthly performance report");
    }

    if (client.packageType == 'Performance' && client.campaigns > 0) {
      items.add(
        "Ad Campaigns: \${client.campaigns} (Target Reach: \${client.campaignReach})",
      );
    }

    for (var addOn in selectedAddOns) {
      String desc = addOn.description != null && addOn.description!.isNotEmpty
          ? " - \${addOn.description}"
          : "";
      items.add(
        "Add-On: \${addOn.type}\$desc (\\u20B9\${addOn.amount.toStringAsFixed(0)})",
      );
    }

    return items
        .map(
          (item) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2),
                  child: pw.CustomPaint(
                    size: const PdfPoint(10, 10),
                    painter: (PdfGraphics canvas, PdfPoint size) {
                      canvas.setColor(_tealColor);
                      canvas.setLineWidth(2);
                      canvas.moveTo(2, 5);
                      canvas.lineTo(4.5, 7.5);
                      canvas.lineTo(9, 2);
                      canvas.strokePath();
                    },
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: pw.Text(
                    item,
                    style: pw.TextStyle(
                      color: _darkText,
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }""";

  String newChecklists = """  static List<pw.Widget> _buildDynamicChecklist(Client client, DateTime month) {
    List<String> items = [];

    items.add("Social Media Strategy (\${client.packageType} Package)");

    int totalPosts =
        (client.weeklyPosts + client.weeklyReels + client.weeklyCarousels) * 4;
    if (totalPosts > 0) {
      items.add(
        "\$totalPosts+ Posts/Month (Including \${client.weeklyReels * 4} Reels & \${client.weeklyCarousels * 4} Carousels)",
      );
    }

    if (client.weeklyStories > 0) {
      items.add("\${client.weeklyStories * 4}+ Stories/Month");
    }

    if (client.postRequirements.isNotEmpty &&
        client.postRequirements != 'TBD') {
      items.add("Requirements: \${client.postRequirements}");
    }

    if (client.packageType == 'Performance' && client.campaigns > 0) {
      items.add(
        "Ad Campaigns: \${client.campaigns} (Target Reach: \${client.campaignReach})",
      );
    }

    return items
        .map(
          (item) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2),
                  child: pw.CustomPaint(
                    size: const PdfPoint(10, 10),
                    painter: (PdfGraphics canvas, PdfPoint size) {
                      canvas.setColor(_tealColor);
                      canvas.setLineWidth(2);
                      canvas.moveTo(2, 5);
                      canvas.lineTo(4.5, 7.5);
                      canvas.lineTo(9, 2);
                      canvas.strokePath();
                    },
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: pw.Text(
                    item,
                    style: pw.TextStyle(
                      color: _darkText,
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  static List<pw.Widget> _buildAddOnsList(List<ClientAddOn> selectedAddOns) {
    List<String> items = [];
    for (var addOn in selectedAddOns) {
      String desc = addOn.description != null && addOn.description!.isNotEmpty
          ? " - \${addOn.description}"
          : "";
      items.add(
        "\${addOn.type}\$desc (\\u20B9\${addOn.amount.toStringAsFixed(0)})",
      );
    }

    return items
        .map(
          (item) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2),
                  child: pw.CustomPaint(
                    size: const PdfPoint(10, 10),
                    painter: (PdfGraphics canvas, PdfPoint size) {
                      canvas.setColor(_tealColor);
                      canvas.setLineWidth(2);
                      canvas.moveTo(2, 5);
                      canvas.lineTo(4.5, 7.5);
                      canvas.lineTo(9, 2);
                      canvas.strokePath();
                    },
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: pw.Text(
                    item,
                    style: pw.TextStyle(
                      color: _darkText,
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }""";

  content = content.replaceAll(oldChecklistFunc, newChecklists);

  file.writeAsStringSync(content);
  print("Invoice layout updated.");
}
