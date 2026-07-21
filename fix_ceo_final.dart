import 'dart:io';

void fixDashboard(String path) {
  final f = File(path);
  String c = f.readAsStringSync();

  // Fix 1: _showEditMemberDialog
  // Add deductionCtrl
  if (!c.contains(
    'final deductionCtrl = TextEditingController(text: e.pendingPayDeduction.toString());',
  )) {
    c = c.replaceFirst(
      'final rateCtrl3 = TextEditingController(text: e.perSkuRate.toString());',
      'final rateCtrl3 = TextEditingController(text: e.perSkuRate.toString());\n    final deductionCtrl = TextEditingController(text: e.pendingPayDeduction.toString());',
    );
  }

  // Inject SageTextField right after Fixed Monthly Salary
  final monthlySalaryPatternEdit = RegExp(
    r'controller: salaryCtrl,[\s\S]*?label: "Fixed Monthly Salary[^"]*",[\s\S]*?keyboardType: TextInputType.number,\n\s*\),\n\s*const SizedBox\(height: 10\),',
  );
  final matches = monthlySalaryPatternEdit.allMatches(c).toList();
  if (matches.isNotEmpty) {
    if (!c.contains('controller: deductionCtrl')) {
      final insert =
          '\n                  SageTextField(\n                    controller: deductionCtrl,\n                    label: "Deductions (\u20B9)",\n                    keyboardType: TextInputType.number,\n                  ),\n                  const SizedBox(height: 10),';
      c = c.replaceRange(matches[0].end, matches[0].end, insert);
    }
  }

  // Inject into updateEmployee
  if (!c.contains('pendingPayDeduction: double.tryParse(deductionCtrl.text)')) {
    c = c.replaceFirst(
      'perSkuRate: double.tryParse(rateCtrl3.text) ?? 0.0,',
      'perSkuRate: double.tryParse(rateCtrl3.text) ?? 0.0,\n                          pendingPayDeduction: double.tryParse(deductionCtrl.text) ?? 0.0,',
    );
  }

  // Fix 2: _showAddMemberDialog
  // Add deductionCtrl
  if (!c.contains('final deductionCtrl = TextEditingController(text: "0");')) {
    c = c.replaceFirst(
      'final rateCtrl3 = TextEditingController(text: "0");',
      'final rateCtrl3 = TextEditingController(text: "0");\n    final deductionCtrl = TextEditingController(text: "0");',
    );
  }

  // Inject SageTextField right after Fixed Monthly Salary
  if (matches.length > 1) {
    // we already modified c, we have to find again.
    final matches2 = monthlySalaryPatternEdit.allMatches(c).toList();
    if (matches2.length > 1) {
      final insert =
          '\n                  SageTextField(\n                    controller: deductionCtrl,\n                    label: "Deductions (\u20B9)",\n                    keyboardType: TextInputType.number,\n                  ),\n                  const SizedBox(height: 10),';
      // It's possible the first match string changed indices, but the second match is further down.
      // Actually let's just do it dynamically.
      int editIndex = c.indexOf('void _showAddMemberDialog');
      if (editIndex != -1) {
        String sub = c.substring(editIndex);
        final m = monthlySalaryPatternEdit.firstMatch(sub);
        if (m != null && !sub.contains('controller: deductionCtrl')) {
          c = c.replaceRange(editIndex + m.end, editIndex + m.end, insert);
        }
      }
    }
  }

  // Inject into addEmployee
  int addIndex = c.indexOf('void _showAddMemberDialog');
  if (addIndex != -1) {
    String sub = c.substring(addIndex);
    if (!sub.contains(
      'pendingPayDeduction: double.tryParse(deductionCtrl.text)',
    )) {
      final m = RegExp(
        r'perSkuRate: double.tryParse\(rateCtrl3.text\) \?\? 0.0,',
      ).firstMatch(sub);
      if (m != null) {
        c = c.replaceRange(
          addIndex + m.start,
          addIndex + m.end,
          'perSkuRate: double.tryParse(rateCtrl3.text) ?? 0.0,\n                          pendingPayDeduction: double.tryParse(deductionCtrl.text) ?? 0.0,',
        );
      }
    }
  }

  // Re-run the symbol fix that was lost from ceo_dashboard
  c = c.replaceAll('â‚¹', '\u20B9');

  f.writeAsStringSync(c);
  print('Done $path');
}

void main() {
  fixDashboard('lib/screens/ceo_dashboard.dart');
  fixDashboard('lib/screens/cofounder_dashboard.dart');
}
