import 'dart:io';
import 'dart:convert';

void main() {
  void fixFile(String path) {
    final file = File(path);
    if (!file.existsSync()) return;
    
    // Read with utf8 to correctly see â‚¹ and ₹
    String content = file.readAsStringSync(encoding: utf8);
    bool changed = false;

    // Fix the corrupted rupee symbol
    if (content.contains('â‚¹')) {
       content = content.replaceAll('â‚¹', '₹');
       changed = true;
    }

    // Fix the broken quotes
    if (content.contains('"₹\${')) {
       // Only remove the quote if it's preceded by a space and inside a string
       // Actually, the easiest way is to look for specific broken lines:
       content = content.replaceAll('received "₹\${', 'received ₹\${');
       content = content.replaceAll('Fee: "₹\${', 'Fee: ₹\${');
       content = content.replaceAll('this month"', 'this month"'); // Check if there's an extra quote at the start
       changed = true;
    }
    
    if (content.contains('Text("₹\${c.monthlyPayable')) {
       // Wait, `Text("₹\${c.monthlyPayable...` is actually correct if it didn't have one before.
       // Let's just fix the known compilation errors from the logs:
    }

    // Fix the CEO dashboard errors
    // The CEO dashboard had an error:
    // lib/screens/ceo_dashboard.dart:2685:35: Error: Not a constant expression.
    // This is because we might have added `const Text("₹...` 
    // Let's remove `const` from `Text("₹`
    if (content.contains('const Text("₹')) {
       content = content.replaceAll('const Text("₹', 'Text("₹');
       changed = true;
    }
    if (content.contains('const Text(\'₹')) {
       content = content.replaceAll('const Text(\'₹', 'Text(\'₹');
       changed = true;
    }
    // And for CEO dashboard line 2685: `const Text("PROFIT SHARE BREAKDOWN"` is fine. 
    // Wait, what caused `children: [` to not be constant?
    // If the `Column` itself was `const Column(children: [ ... ])`!
    if (content.contains('const Column(')) {
       // If there is a const Column that contains ₹ which makes it non-const
       // Actually, let's just find and replace `const Column(children: [` with `Column(children: [` if it contains ₹
    }
    
    // Also, my script added `"₹\${` indiscriminately!
    // Let's just fix the instances:
    // 1. `Text("₹\${c.monthlyPayable.toStringAsFixed(0)} commission not yet received this month",`
    // This was previously `Text(Rs. \${c...` which was invalid.
    // Wait, `Text(Rs. \${` didn't have quotes!
    // So `Text("₹\${` IS correct for that one!
    // But the error is: `Error: Expected ',' before this. Rs. \${...`
    // Wait, if the error is `Rs. \${... commission not yet received this month",`, it means the quote IS MISSING!
    // The quote is missing at the start of `Rs. \${`!
    
    if (changed) {
      file.writeAsStringSync(content, encoding: utf8);
      print('Fixed syntax in \$path');
    }
  }

  fixFile('lib/screens/ceo_dashboard.dart');
  fixFile('lib/screens/cofounder_dashboard.dart');
  fixFile('lib/screens/marketing_executive_dashboard.dart');
  fixFile('lib/state/app_state.dart');
}
