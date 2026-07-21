import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';
import 'package:sage_mainframe/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InvoiceService {
  static final _tealColor = PdfColor.fromHex('#0F7A85');
  static final _orangeColor = PdfColor.fromHex('#F27C54');
  static final _darkText = PdfColor.fromHex('#212121');
  static final _greyText = PdfColor.fromHex('#757575');

  static Future<int> _getNextInvoiceNumber() async {
    final docRef = FirebaseFirestore.instance
        .collection('metadata')
        .doc('invoiceCounter');
    return await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        transaction.set(docRef, {'lastNumber': 125});
        return 125;
      }
      int lastNumber = snapshot.data()?['lastNumber'] ?? 124;
      int nextNumber = lastNumber + 1;
      transaction.update(docRef, {'lastNumber': nextNumber});
      return nextNumber;
    });
  }

  static Future<void> generateAndShareInvoice(
    Client client,
    DateTime month,
    {List<ClientAddOn> selectedAddOns = const [], double monthDiscount = 0.0}
  ) async {
    final pdf = pw.Document();

    final theme = pw.ThemeData.withFont(
      base: await PdfGoogleFonts.robotoRegular(),
      bold: await PdfGoogleFonts.robotoBold(),
    );

    int nextNum = await _getNextInvoiceNumber();
    final invoiceNo = nextNum.toRadixString(16).toUpperCase().padLeft(4, '0');

    // Load invoice logo
    final ByteData logoData = await rootBundle.load('assets/logo/invoice_logo.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);

    // Load CEO signature
    final ByteData signData = await rootBundle.load('assets/logo/ceo e sign.png');
    final Uint8List signBytes = signData.buffer.asUint8List();
    final pw.MemoryImage signImage = pw.MemoryImage(signBytes);

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(0),
        ),
        build: (context) => [
          _buildInvoicePage(client, month, invoiceNo, theme, selectedAddOns, logoImage, signImage, monthDiscount),
        ],
      ),
    );

    final bytes = await pdf.save();

    if (kIsWeb) {
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', 'Invoice_$invoiceNo.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      await Printing.sharePdf(bytes: bytes, filename: 'Invoice_$invoiceNo.pdf');
    }
  }



  static pw.Widget _buildInvoicePage(
    Client client,
    DateTime month,
    String invoiceNo,
    pw.ThemeData theme,
    List<ClientAddOn> selectedAddOns,
    pw.MemoryImage logoImage,
    pw.MemoryImage signImage,
    double monthDiscount,
  ) {
    return pw.Container(
      height: PdfPageFormat.a4.height,
      width: PdfPageFormat.a4.width,
      child: pw.Stack(
        children: [
          // Header Background
          pw.Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: pw.Column(
              children: [
                pw.Container(
                  height: 30,
                  width: double.infinity,
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 1,
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              top: pw.BorderSide(color: _orangeColor, width: 4),
                            ),
                          ),
                        ),
                      ),
                      pw.Container(width: 250, height: 30, color: _tealColor),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Footer Background
          pw.Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: pw.Container(
              height: 40,
              width: double.infinity,
              child: pw.Row(
                children: [
                  pw.Container(width: 300, height: 40, color: _tealColor),
                  pw.SizedBox(width: 10),
                  pw.Container(width: 20, height: 40, color: _orangeColor),
                  pw.SizedBox(width: 5),
                  pw.Container(width: 10, height: 40, color: _orangeColor),
                ],
              ),
            ),
          ),

          // Main Content
          pw.Positioned.fill(
            child: pw.Padding(
              padding: const pw.EdgeInsets.only(
                top: 50,
                left: 40,
                right: 40,
                bottom: 60,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Logo & INVOICE header
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Logo Placeholder
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Image(logoImage, height: 60),
                          pw.SizedBox(height: 15),
                          pw.Text(
                            "Invoice To",
                            style: pw.TextStyle(
                              color: _tealColor,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          pw.RichText(
                            text: pw.TextSpan(
                              children: [
                                pw.TextSpan(
                                  text: "Name: ",
                                  style: pw.TextStyle(
                                    color: _tealColor,
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.TextSpan(
                                  text: client.name,
                                  style: pw.TextStyle(
                                    color: _orangeColor,
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // INVOICE Text
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            "INVOICE",
                            style: pw.TextStyle(
                              color: _orangeColor,
                              fontSize: 36,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          pw.SizedBox(height: 15),
                          _buildHeaderRow("Invoice No:", "#$invoiceNo"),
                          pw.SizedBox(height: 5),
                          _buildHeaderRow(
                            "Invoice Date:",
                            DateFormat('dd MMMM, yyyy').format(DateTime.now()),
                          ),
                          pw.SizedBox(height: 5),
                          _buildHeaderRow(
                            "For the month of:",
                            DateFormat('MMMM').format(month).toUpperCase(),
                            isOrangeValue: true,
                          ),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 30),

                  // Location Bar
                  pw.Container(
                    width: double.infinity,
                    color: _tealColor,
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    child: pw.Row(
                      children: [
                        // Map Pin Icon placeholder
                        pw.Container(
                          width: 14,
                          height: 14,
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                            shape: pw.BoxShape.circle,
                          ),
                          child: pw.Center(
                            child: pw.Container(
                              width: 6,
                              height: 6,
                              decoration: pw.BoxDecoration(
                                color: _orangeColor,
                                shape: pw.BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Text(
                          "Bolpur, Shantiniketan (731204)",
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Container(
                    width: double.infinity,
                    height: 1,
                    color: _orangeColor,
                  ),

                  pw.SizedBox(height: 20),

                  // Details Row
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      // Company Contact
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildContactRow("Phone:", "+91 7001590377"),
                          pw.SizedBox(height: 3),
                          _buildContactRow(
                            "Email:",
                            "priyajitbhowmik7@gmail.com",
                          ),
                          pw.SizedBox(height: 3),
                          _buildContactRow(
                            "Address:",
                            "Bolpur, Shantiniketan (731204)",
                          ),
                        ],
                      ),
                      // Payment Method
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "PAYMENT METHOD",
                            style: pw.TextStyle(
                              color: _darkText,
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                          _buildPaymentRow("Account No:", "06840110084304"),
                          pw.SizedBox(height: 3),
                          _buildPaymentRow("Account Name:", "Sohini Roy"),
                          pw.SizedBox(height: 3),
                          _buildPaymentRow("IFSC:", "UCBA0000684"),
                          pw.SizedBox(height: 3),
                          _buildPaymentRow(
                            "UPI ID:",
                            "sohini.raya.roy0309-8@okhdfcbank",
                          ),
                        ],
                      ),
                    ],
                  ),



                  // Two column layout for Deliverables and Add-Ons
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Left Column: Deliverables
                      pw.Expanded(
                        flex: 1,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
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
                          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
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
                  ),

                  pw.SizedBox(height: 10),
                  pw.Divider(color: _greyText, thickness: 0.5),
                  pw.SizedBox(height: 20),

                  // Bottom Area
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
                                pw.Image(signImage, height: 40),
                                pw.SizedBox(height: 2),
                                pw.Container(
                                  width: 120,
                                  height: 1,
                                  color: _darkText,
                                ),
                                pw.SizedBox(height: 5),
                                pw.Text(
                                  "Sohini Roy\nCEO, Market Sages",
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

                      // Right Totals
                      pw.Expanded(
                        flex: 4,
                        child: _buildTotalsColumn(client, month, selectedAddOns, monthDiscount),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildHeaderRow(
    String label,
    String value, {
    bool isOrangeValue = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(color: _tealColor, fontSize: 10),
        ),
        pw.SizedBox(width: 10),
        pw.Text(
          value,
          style: pw.TextStyle(
            color: isOrangeValue ? _orangeColor : _tealColor,
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTotalsColumn(Client client, DateTime month, List<ClientAddOn> selectedAddOns, double overrideMonthDiscount) {
    double baseAmount = client.monthlyPayable;
    double discountAmount = overrideMonthDiscount > 0 ? overrideMonthDiscount : (client.monthlyDiscounts[month.month.toString()] ?? 0);
    double addOnsTotal = selectedAddOns.fold(0, (sum, a) => sum + (a.amount - a.discount));
    double websiteHandlingFee = client.isWebsiteHandlingActive ? client.websiteHandlingFee : 0;
    double grandTotal = baseAmount + websiteHandlingFee + addOnsTotal - discountAmount;
    if (client.ecomPaymentType == 'Per SKU') {
      grandTotal = client.getPayableForMonth(month.month, month.year) + addOnsTotal - discountAmount;
      baseAmount = grandTotal - addOnsTotal + discountAmount;
    }

    return pw.Column(
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
    );
  }

  static pw.Widget _buildContactRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Container(
          width: 50,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              color: _darkText,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Text(value, style: pw.TextStyle(color: _darkText, fontSize: 10)),
      ],
    );
  }

  static pw.Widget _buildPaymentRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Container(
          width: 80,
          child: pw.Text(
            label,
            style: pw.TextStyle(color: _darkText, fontSize: 10),
          ),
        ),
        pw.Text(value, style: pw.TextStyle(color: _darkText, fontSize: 10)),
      ],
    );
  }

  static List<pw.Widget> _buildDynamicChecklist(Client client, DateTime month) {
    List<String> items = [];

    if (client.serviceType.toLowerCase().contains('commerce')) {
      items.add("E-Commerce Management");
      items.add("Listing, Catalogue, A+ Content");
      if (client.postRequirements.isNotEmpty && client.postRequirements != 'TBD') {
        items.add(client.postRequirements);
      }
    } else if (client.serviceType.toLowerCase().contains('video')) {
      items.add("Video Production Services");
      if (client.postRequirements.isNotEmpty && client.postRequirements != 'TBD') {
        items.add(client.postRequirements);
      }
    } else {
      items.add("Social Media Strategy (${client.packageType} Package)");

      int totalPosts =
          (client.weeklyPosts + client.weeklyReels + client.weeklyCarousels) * 4;
      if (totalPosts > 0) {
        items.add(
          "$totalPosts+ Posts/Month (Including ${client.weeklyReels * 4} Reels & ${client.weeklyCarousels * 4} Carousels)",
        );
      }

      if (client.weeklyStories > 0) {
        items.add("${client.weeklyStories * 4}+ Stories/Month");
      }

      if (client.postRequirements.isNotEmpty &&
          client.postRequirements != 'TBD') {
        items.add(client.postRequirements);
      }

      if (client.packageType == 'Performance' && client.campaigns > 0) {
        items.add(
          "Ad Campaigns: ${client.campaigns} (Target Reach: ${client.campaignReach})",
        );
      }
    }

    return items
        .map(
          (item) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 6),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 0),
                  child: pw.Text(
                    "•",
                    style: pw.TextStyle(
                      color: _tealColor,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Container(
                  width: 220,
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
          ? " - ${addOn.description}"
          : "";
      items.add(
        "${addOn.type}$desc (\u20B9${addOn.amount.toStringAsFixed(0)})",
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
                  padding: const pw.EdgeInsets.only(top: 0),
                  child: pw.Text(
                    "•",
                    style: pw.TextStyle(
                      color: _tealColor,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Container(
                  width: 220,
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
}

