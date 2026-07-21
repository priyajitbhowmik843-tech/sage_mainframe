import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() async {
  final pdf = pw.Document();

  final _tealColor = PdfColor.fromHex('#0b7f8c');
  final _darkText = PdfColor.fromHex('#212121');

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
      ),
      build: (pw.Context context) => [
        pw.Container(
          height: PdfPageFormat.a4.height,
          width: PdfPageFormat.a4.width,
          child: pw.Stack(
            children: [
              pw.Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: pw.Column(
                  children: [
                    pw.Text("Top Area"),
                    pw.Expanded(
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            flex: 1,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                              children: [
                                pw.Container(
                                  color: _tealColor,
                                  padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 8,
                                  ),
                                  child: pw.Text("DELIVERABLES"),
                                ),
                                pw.SizedBox(height: 10),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.only(bottom: 6),
                                  child: pw.Row(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Padding(
                                        padding: const pw.EdgeInsets.only(
                                          top: 0,
                                        ),
                                        child: pw.Text("•"),
                                      ),
                                      pw.SizedBox(width: 8),
                                      pw.Container(
                                        width: 220,
                                        child: pw.Text(
                                          "This is a test deliverable",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(width: 20),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                              children: [
                                pw.Container(
                                  color: _tealColor,
                                  padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 8,
                                  ),
                                  child: pw.Text("ADD-ONS"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Text("Bottom Area"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  final bytes = await pdf.save();
  final file = File("test2.pdf");
  file.writeAsBytesSync(bytes);
  print("Saved test2.pdf");
}
