import 'dart:io';

void main() {
  final files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cofounder_dashboard.dart',
  ];

  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) continue;
    var content = file.readAsStringSync();

    // 1. Add _getRoleColor function if not present
    if (!content.contains('Color _getRoleColor(String role)')) {
      final roleColorFunc = '''
  Color _getRoleColor(String role) {
    final r = role.toLowerCase();
    if (r.contains('ceo')) return const Color(0xFFFFB3BA);
    if (r.contains('founder') || r.contains('cfo')) return const Color(0xFFFFDFBA);
    if (r.contains('videographer')) return const Color(0xFFBAE1FF);
    if (r.contains('video editor')) return const Color(0xFFE6B3FF);
    if (r.contains('marketing')) return const Color(0xFFBAFFC9);
    return const Color(0xFFFFFFBA);
  }

  Widget _buildPersonnelTab() {''';
      content = content.replaceAll('  Widget _buildPersonnelTab() {', roleColorFunc);
    }

    // 2. Replace persona color logic
    content = content.replaceAll(
      'final color = pastelColors[i % pastelColors.length];',
      'final color = _getRoleColor(p.roleLabel);'
    );
    // Replace employee color logic (it uses the same variable name, but for employees we need to use employee.role)
    // Wait, in the map it says `final color = pastelColors[i % pastelColors.length];` for employees too.
    // Let's explicitly replace the employee one:
    content = content.replaceAll(
      '''
        ...state.employees.asMap().entries.map((entry) {
          final i = entry.key + AppState.personas.length;
          final employee = entry.value;
          final color = _getRoleColor(p.roleLabel);''', // It would have been replaced by the previous replaceAll!
      '''
        ...state.employees.asMap().entries.map((entry) {
          final i = entry.key + AppState.personas.length;
          final employee = entry.value;
          final color = _getRoleColor(employee.role);'''
    );

    // 3. Replace Persona ExpansionTile leading
    final oldPersonaLeading = '''
              leading: Container(
                width: 88, height: 88,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                alignment: Alignment.center,
                child: ClipOval(child: Image.asset(availableAvatars[p.id.hashCode.abs() % availableAvatars.length], fit: BoxFit.cover, width: 88, height: 88)),
              ),
              title: Text(p.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
              subtitle: Text(p.roleLabel, style: const TextStyle(fontSize: 10, color: Colors.black54)),
''';
    final newPersonaTitle = '''
              title: Row(
                children: [
                  Container(
                    width: 72, height: 72,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: ClipOval(child: Image.asset(availableAvatars[p.id.hashCode.abs() % availableAvatars.length], fit: BoxFit.cover, width: 72, height: 72)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                        Text(p.roleLabel, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
''';
    content = content.replaceAll(oldPersonaLeading, newPersonaTitle);

    // 4. Replace Employee ExpansionTile leading and fix corrupted subtitle
    // I need to use RegExp because the corrupted text might vary slightly.
    final employeePattern = RegExp(
      r'leading:\s*Container\([\s\S]*?ClipOval\([\s\S]*?Image\.asset\(availableAvatars\[employee\.avatar\s*%\s*availableAvatars\.length\],\s*fit:\s*BoxFit\.cover,\s*width:\s*88,\s*height:\s*88\)\),\s*\),\s*title:\s*Text\(employee\.name[^)]*\)\),\s*subtitle:\s*Text\("[^"]*\$\{employee\.role\}\s*//\s*\$\{employee\.department\}"[^)]*\)\),'
    );
    final newEmployeeTitle = '''
              title: Row(
                children: [
                  Container(
                    width: 72, height: 72,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: ClipOval(child: Image.asset(availableAvatars[employee.avatar % availableAvatars.length], fit: BoxFit.cover, width: 72, height: 72)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(employee.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                        Text("\${employee.role} // \${employee.department}", style: const TextStyle(fontSize: 10, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
''';
    content = content.replaceAll(employeePattern, newEmployeeTitle);

    // 5. Fix corrupted contact icons inside employee tile
    // "dY"z ${employee.phone" -> "📞 ${employee.phone"
    // "o%,? ${employee.email" -> "✉️ ${employee.email"
    // "dY? ${employee.address" -> "📍 ${employee.address"
    content = content.replaceAll(RegExp(r'"[^"]*\$\{employee\.phone\.isNotEmpty'), '"📞 \${employee.phone.isNotEmpty');
    content = content.replaceAll(RegExp(r'"[^"]*\$\{employee\.email\.isNotEmpty'), '"✉️ \${employee.email.isNotEmpty');
    content = content.replaceAll(RegExp(r'"[^"]*\$\{employee\.address\.isNotEmpty'), '"📍 \${employee.address.isNotEmpty');

    file.writeAsStringSync(content);
    print('Updated \$path');
  }
}
