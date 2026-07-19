import 'dart:io';

void main() {
  final f = File('lib/screens/ceo_dashboard.dart');
  String c = f.readAsStringSync();
  
  // Find `final rateCtrl3 = TextEditingController(text: e.perSkuRate.toString());` in _showEditMemberDialog
  c = c.replaceFirst(
    'final rateCtrl3 = TextEditingController(text: e.perSkuRate.toString());',
    'final rateCtrl3 = TextEditingController(text: e.perSkuRate.toString());\n    final deductionCtrl = TextEditingController(text: e.pendingPayDeduction.toString());'
  );

  // Find the SageTextField for Fixed Monthly Salary in _showEditMemberDialog and insert the new field after the rateCtrl3 or right after the Monthly Salary
  // Let's insert after rateCtrl3 field
  c = c.replaceFirst(
    'controller: rateCtrl3,\n                    label: "Per SKU Rate (\\u20B9)",\n                    keyboardType: TextInputType.number,\n                  ),\n                  const SizedBox(height: 10),',
    'controller: rateCtrl3,\n                    label: "Per SKU Rate (\\u20B9)",\n                    keyboardType: TextInputType.number,\n                  ),\n                  const SizedBox(height: 10),\n                  SageTextField(\n                    controller: deductionCtrl,\n                    label: "Deductions (\\u20B9)",\n                    keyboardType: TextInputType.number,\n                  ),\n                  const SizedBox(height: 10),'
  );

  // Find the updateEmployee call in _showEditMemberDialog
  c = c.replaceFirst(
    'perSkuRate: double.tryParse(rateCtrl3.text) ?? 0.0,',
    'perSkuRate: double.tryParse(rateCtrl3.text) ?? 0.0,\n                          pendingPayDeduction: double.tryParse(deductionCtrl.text) ?? 0.0,'
  );

  f.writeAsStringSync(c);
  print('Done ceo_dashboard.dart');
}
