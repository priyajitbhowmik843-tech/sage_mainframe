import 'dart:io';

void main() {
  void fixFile(String path) {
    final file = File(path);
    if (!file.existsSync()) return;

    String content = file.readAsStringSync();
    bool changed = false;

    // specific app_state.dart fixes
    if (content.contains('Rs. \${c.monthlyPayable.toStringAsFixed(0)}')) {
      content = content.replaceAll(
        'Rs. \${c.monthlyPayable.toStringAsFixed(0)}',
        '₹\${c.monthlyPayable.toStringAsFixed(0)}',
      );
      changed = true;
    }
    if (content.contains('Rs. \${amount.toStringAsFixed(0)})')) {
      content = content.replaceAll(
        'Rs. \${amount.toStringAsFixed(0)})',
        '(₹\${amount.toStringAsFixed(0)})',
      );
      changed = true;
    }
    if (content.contains('Rs. \${amount.toStringAsFixed(0)}\'')) {
      content = content.replaceAll(
        'Rs. \${amount.toStringAsFixed(0)}\'',
        '₹\${amount.toStringAsFixed(0)}\'',
      );
      changed = true;
    }
    if (content.contains(
      'Rs. \${entry.isIncome ? \'+\' : \'-\'}\${entry.amount}]',
    )) {
      content = content.replaceAll(
        'Rs. \${entry.isIncome ? \'+\' : \'-\'}\${entry.amount}]',
        '[\${entry.isIncome ? \'+\' : \'-\'}\${entry.amount}]',
      );
      changed = true;
    }
    if (content.contains(
      'Rs. \${entry.isIncome ? \'+\' : \'-\'}Rs. \${entry.amount.toStringAsFixed(0)}]',
    )) {
      content = content.replaceAll(
        'Rs. \${entry.isIncome ? \'+\' : \'-\'}Rs. \${entry.amount.toStringAsFixed(0)}]',
        '[\${entry.isIncome ? \'+\' : \'-\'}₹\${entry.amount.toStringAsFixed(0)}]',
      );
      changed = true;
    }

    if (changed) {
      file.writeAsStringSync(content);
      print('Fixed manual bugs in \$path');
    }
  }

  fixFile('lib/state/app_state.dart');
}
