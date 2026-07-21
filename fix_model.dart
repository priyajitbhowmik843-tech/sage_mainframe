import 'dart:io';

void main() {
  final file = File(
    'c:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/lib/models/models.dart',
  );
  var content = file.readAsStringSync();

  final fromDb = '''
        pendingPayAmount: (data['pendingPayAmount'] ?? 0.0).toDouble(),
        preferredName: data['preferredName'] ?? '',
        workLocation: data['workLocation'] ?? '',
        emergencyContact: data['emergencyContact'] ?? '',
        professionalBio: data['professionalBio'] ?? '',
        keySkills: List<String>.from(data['keySkills'] ?? []),
        strengths: List<String>.from(data['strengths'] ?? []),
        workStylePreference: data['workStylePreference'] ?? '',
        interests: data['interests'] ?? '',
''';

  // Use string replace instead of regex to avoid issues.
  content = content.replaceAll(
    "        pendingPayAmount: (data['pendingPayAmount'] ?? 0.0).toDouble(),",
    fromDb,
  );

  file.writeAsStringSync(content);
  print("models.dart updated.");
}
