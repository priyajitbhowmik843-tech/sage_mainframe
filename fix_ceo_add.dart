import 'dart:io';

void fixFile(String path) {
  final f = File(path);
  String c = f.readAsStringSync();

  // Find _showAddMemberDialog and inject deductionCtrl
  final addMemberPattern = RegExp(
    r'void _showAddMemberDialog[\s\S]*?final rateCtrl3 = TextEditingController\(text: "0"\);',
  );
  final match = addMemberPattern.firstMatch(c);
  if (match != null) {
    c = c.replaceRange(
      match.start,
      match.end,
      '${match.group(0)}\n    final deductionCtrl = TextEditingController(text: "0");',
    );
  }

  // Find the SageTextField in _showAddMemberDialog for rateCtrl3 and insert deductionCtrl
  // We can just search for rateCtrl3 and Per SKU Rate that appears AFTER _showAddMemberDialog
  final textPattern = RegExp(
    r'controller: rateCtrl3,[\s\S]*?label: "Per SKU Rate \(\\u20B9\)",[\s\S]*?keyboardType: TextInputType.number,\n\s*\),\n\s*const SizedBox\(height: 10\),',
  );
  final matches = textPattern.allMatches(c).toList();
  // The first match is in edit dialog (already replaced?), wait, we only replaced it manually using dart in edit dialog.
  // Actually, we replaced the first occurrence in the file.
  // Let's just blindly replace the one that comes AFTER _showAddMemberDialog.
  final addMemberIndex = c.indexOf('void _showAddMemberDialog');
  if (addMemberIndex != -1) {
    final searchBlock = c.substring(addMemberIndex);
    final textMatch = textPattern.firstMatch(searchBlock);
    if (textMatch != null) {
      final insertText =
          '\n                  SageTextField(\n                    controller: deductionCtrl,\n                    label: "Deductions (\\u20B9)",\n                    keyboardType: TextInputType.number,\n                  ),\n                  const SizedBox(height: 10),';
      c = c.replaceRange(
        addMemberIndex + textMatch.end,
        addMemberIndex + textMatch.end,
        insertText,
      );
    }
  }

  f.writeAsStringSync(c);
  print('Done $path');
}

void main() {
  fixFile('lib/screens/ceo_dashboard.dart');
  fixFile('lib/screens/cofounder_dashboard.dart');
}
