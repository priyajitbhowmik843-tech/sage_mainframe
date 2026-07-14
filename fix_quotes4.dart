import 'dart:io';

void main() {
  void fixQuotes(String path) {
    final file = File(path);
    if (!file.existsSync()) return;

    final content = file.readAsStringSync();
    
    // Pattern to find ` "₹\${...}`
    // It captures:
    // 1: the space before the quote (or any char really, let's just match the quote and ₹)
    // Actually let's just match `"₹\$\{` and the content inside the braces, and the character after the closing brace.
    final regex = RegExp(r'"₹\$\{([^}]+)\}(.)');
    
    final newContent = content.replaceAllMapped(regex, (match) {
      final inside = match.group(1)!;
      final after = match.group(2)!;
      
      if (after == ')') {
        // It was meant to be a parenthesis block `(\${...})`
        // But wait, what if it was `"LEADS "₹\${...})"` ?
        // We want to replace `"₹\$\{...})` with `(\$\{...})`
        // Actually, if we replace `"₹\$\{` with `(\$\{`, the string becomes `"LEADS (\$\{...})` which is valid!
        return '(\${' + inside + '}' + after;
      } else {
        // It was meant to be a currency `₹\${...}`
        // So `"Salary: "₹\${...}/mo` -> `"Salary: ₹\${...}/mo`
        // So we just replace `"₹\$\{` with `₹\$\{`
        return '₹\${' + inside + '}' + after;
      }
    });

    if (newContent != content) {
      file.writeAsStringSync(newContent);
      print('Fixed in \$path');
    }
  }

  fixQuotes('lib/screens/ceo_dashboard.dart');
  fixQuotes('lib/screens/cofounder_dashboard.dart');
  fixQuotes('lib/screens/marketing_executive_dashboard.dart');
  fixQuotes('lib/state/app_state.dart');
}
