import 'dart:io';

void main() {
  final files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cofounder_dashboard.dart',
    'lib/screens/cofounder_dashboard_new.dart',
    'lib/screens/cofounder_dashboard_recovered.dart',
  ];

  final insertBlock = '''
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("\\u{1F4DE} \${p.phone.isNotEmpty ? p.phone : 'Not Provided'}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      Text("\\u{2709} \${p.email.isNotEmpty ? p.email : 'Not Provided'}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      Text("\\u{1F4CD} \${p.address.isNotEmpty ? p.address : 'Not Provided'}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                    ],
                  ),
                ),''';

  for (final file in files) {
    final f = File(file);
    if (!f.existsSync()) continue;
    
    var content = f.readAsStringSync();
    
    final pattern = '''              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.black, width: 1.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("System Core Persona"''';
                      
    if (content.contains(pattern)) {
        final replacement = insertBlock + '''\n                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.black, width: 1.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("System Core Persona"''';
        content = content.replaceFirst(pattern, replacement);
        f.writeAsStringSync(content);
        print('Fixed ' + file);
    } else {
        print('Could not find pattern in ' + file);
    }
  }
}
