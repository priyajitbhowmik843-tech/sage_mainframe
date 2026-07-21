import 'dart:io';

void main() {
  final filesToEdit = [
    'lib/screens/employee_dashboard.dart',
    'lib/screens/marketing_executive_dashboard.dart',
    'lib/screens/videographer_dashboard.dart',
  ];

  for (var filePath in filesToEdit) {
    final file = File(filePath);
    if (!file.existsSync()) continue;
    var content = file.readAsStringSync();

    final regex = RegExp(
      r'Center\(\s*child: Container\(\s*width: 140, height: 140,.*?child: ClipOval\(child: Image\.asset\((.*?), fit: BoxFit\.cover, width: 88, height: 88\)\),\s*\),\s*\),',
      multiLine: true,
      dotAll: true,
    );

    content = content.replaceAllMapped(regex, (match) {
      final avatarPath = match.group(1);
      return '''Center(
                  child: ClipOval(
                    child: Image.asset($avatarPath, fit: BoxFit.cover, width: 140, height: 140),
                  ),
                ),''';
    });

    file.writeAsStringSync(content);
    print("Updated \$filePath");
  }
}
