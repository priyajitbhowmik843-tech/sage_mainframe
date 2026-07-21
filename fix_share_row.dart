import 'dart:io';

void replaceInFile(String path) {
  final file = File(path);
  var content = file.readAsStringSync();

  // Replace the broken shareRow text.
  // There are 2 instances in each file (one for Main Pool, one for Video Pool)
  final badShareRowText =
      'Text("₹", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),';
  final goodShareRowText =
      'Text("₹\${amount.toStringAsFixed(amount == amount.truncateToDouble() ? 0 : 2)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),';

  content = content.replaceAll(badShareRowText, goodShareRowText);

  // Wait, let's look at the actual bytes or string in the file.
  // In the grep output, it showed: Text(",1", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color))
  // The symbol was corrupted. Let's do a regex replace to catch whatever that symbol is.
  final regex = RegExp(
    r'Text\("[^"]+", style: TextStyle\(fontWeight: FontWeight.bold, fontSize: 14, color: color\)\),',
  );
  content = content.replaceAll(regex, goodShareRowText);

  file.writeAsStringSync(content);
  print('\$path fixed');
}

void main() {
  replaceInFile('lib/screens/ceo_dashboard.dart');
  replaceInFile('lib/screens/cofounder_dashboard.dart');
}
