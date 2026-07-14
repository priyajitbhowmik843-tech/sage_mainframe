import 'dart:io';

void main() {
  final filesToEdit = [
    'lib/screens/employee_dashboard.dart',
    'lib/screens/marketing_executive_dashboard.dart',
    'lib/screens/videographer_dashboard.dart'
  ];

  final uiInsert = '''
                      const SizedBox(height: 10),
                      const Text("KEY SKILLS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8,
                        children: ['Editing', 'Sales', 'Design', 'Marketing', 'Coding'].map((skill) {
                          final isSelected = selectedSkills.contains(skill);
                          return FilterChip(
                            label: Text(skill, style: const TextStyle(fontSize: 10)),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  selectedSkills.add(skill);
                                } else {
                                  selectedSkills.remove(skill);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      const Text("STRENGTHS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      Wrap(
                        spacing: 8,
                        children: ['Leadership', 'Problem Solving', 'Creativity', 'Communication'].map((strength) {
                          final isSelected = selectedStrengths.contains(strength);
                          return FilterChip(
                            label: Text(strength, style: const TextStyle(fontSize: 10)),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  selectedStrengths.add(strength);
                                } else {
                                  selectedStrengths.remove(strength);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      const Text("CHOOSE AVATAR", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),''';

  final uiFind = '''
                      const SizedBox(height: 20),
                      const Text("CHOOSE AVATAR", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),''';

  for (var filePath in filesToEdit) {
    final file = File(filePath);
    if (!file.existsSync()) continue;
    
    var content = file.readAsStringSync();
    content = content.replaceFirst(uiFind.trim(), uiInsert.trim());

    final updateFind = '''interests: interestsCtrl.text,''';
    final updateReplace = '''interests: interestsCtrl.text,
                        keySkills: selectedSkills,
                        strengths: selectedStrengths,''';
    content = content.replaceFirst(updateFind, updateReplace);

    file.writeAsStringSync(content);
    print("Updated \$filePath");
  }
}
