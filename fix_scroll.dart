import 'dart:io';

void main() {
  final files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cofounder_dashboard.dart',
  ];

  for (final path in files) {
    final file = File(path);
    var content = file.readAsStringSync();

    // Fix _showSkuLogDetails DataTable
    String oldBlock1 = r'''
                ) : SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
''';
    String newBlock1 = r'''
                ) : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
''';

    content = content.replaceAll(oldBlock1, newBlock1);

    // Fix _showFullClientLedger DataTable
    String oldBlock2 = r'''
              ) : SingleChildScrollView(
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
''';
    String newBlock2 = r'''
              ) : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
''';

    content = content.replaceAll(oldBlock2, newBlock2);

    file.writeAsStringSync(content);
    print("Fixed horizontal scroll for SKU tables in $path");
  }
}
