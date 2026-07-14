import 'dart:io';

void main() {
  final file = File('lib/models/models.dart');
  var content = file.readAsStringSync();

  content = content.replaceAll(
    '  int get dynamicPaymentsDue {',
    '  double get totalAmountDue {\n    double total = 0;\n    int currentYear = DateTime.now().year;\n    for (int i = 1; i <= 12; i++) {\n      if (isMonthDue(i)) {\n        total += getPayableForMonth(i, currentYear);\n      }\n    }\n    return total;\n  }\n\n  int get dynamicPaymentsDue {'
  );

  file.writeAsStringSync(content);
  print("Added totalAmountDue");
}
