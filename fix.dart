import 'dart:io';

void main() {
  final filesToEdit = [
    'lib/screens/employee_dashboard.dart',
    'lib/screens/marketing_executive_dashboard.dart',
    'lib/screens/videographer_dashboard.dart'
  ];

  final uiInsert = '''
                      SageTextField(controller: emailCtrl, label: "Email"),
                      const SizedBox(height: 10),
                      SageTextField(controller: prefNameCtrl, label: "Preferred Name"),
                      const SizedBox(height: 10),
                      SageTextField(controller: emergencyCtrl, label: "Emergency Contact"),
                      const SizedBox(height: 10),
                      SageTextField(controller: bioCtrl, label: "Professional Bio", maxLines: 3),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedWorkLocation,
                        decoration: const InputDecoration(labelText: "Work Location"),
                        items: ['Office', 'Remote', 'Hybrid'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => selectedWorkLocation = v ?? 'Office'),
                        dropdownColor: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedWorkStyle,
                        decoration: const InputDecoration(labelText: "Work Style Preference"),
                        items: ['Independent thinker', 'Team collaborator', 'Detail-oriented', 'Fast executor', 'Strategic planner'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setState(() => selectedWorkStyle = v ?? 'Independent thinker'),
                        dropdownColor: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      SageTextField(controller: interestsCtrl, label: "Interests / Hobbies"),
                      const SizedBox(height: 20),
                      const Text("CHOOSE AVATAR", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),''';

  final uiFind = '''
                      SageTextField(controller: emailCtrl, label: "Email"),
                      const SizedBox(height: 20),
                      const Text("CHOOSE AVATAR", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),''';

  for (var filePath in filesToEdit) {
    final file = File(filePath);
    if (!file.existsSync()) continue;
    
    var content = file.readAsStringSync();

    if (!content.contains('final prefNameCtrl =')) {
      content = content.replaceFirst(
        'final emailCtrl = TextEditingController(text: emp.email);',
        '''final emailCtrl = TextEditingController(text: emp.email);
    final prefNameCtrl = TextEditingController(text: emp.preferredName);
    final emergencyCtrl = TextEditingController(text: emp.emergencyContact);
    final bioCtrl = TextEditingController(text: emp.professionalBio);
    final interestsCtrl = TextEditingController(text: emp.interests);
    
    String selectedWorkLocation = emp.workLocation.isEmpty ? 'Office' : emp.workLocation;
    String selectedWorkStyle = emp.workStylePreference.isEmpty ? 'Independent thinker' : emp.workStylePreference;
    List<String> selectedSkills = List.from(emp.keySkills);
    List<String> selectedStrengths = List.from(emp.strengths);'''
      );
    }

    content = content.replaceFirst(uiFind.trim(), uiInsert.trim());

    content = content.replaceFirst(
      '''email: emailCtrl.text,
                        avatar: selectedAvatar,''',
      '''email: emailCtrl.text,
                        avatar: selectedAvatar,
                        preferredName: prefNameCtrl.text,
                        emergencyContact: emergencyCtrl.text,
                        professionalBio: bioCtrl.text,
                        workLocation: selectedWorkLocation,
                        workStylePreference: selectedWorkStyle,
                        interests: interestsCtrl.text,'''
    );

    final profileFind = '''_profileRow("EMAIL", emp.email.isNotEmpty ? emp.email : '---'),
                const SizedBox(height: 24),''';
    
    final profileReplace = '''_profileRow("EMAIL", emp.email.isNotEmpty ? emp.email : '---'),
                _profileRow("PREFERRED NAME", emp.preferredName.isNotEmpty ? emp.preferredName : '---'),
                _profileRow("EMERGENCY", emp.emergencyContact.isNotEmpty ? emp.emergencyContact : '---'),
                _profileRow("BIO", emp.professionalBio.isNotEmpty ? emp.professionalBio : '---'),
                _profileRow("WORK LOCATION", emp.workLocation.isNotEmpty ? emp.workLocation : '---'),
                _profileRow("WORK STYLE", emp.workStylePreference.isNotEmpty ? emp.workStylePreference : '---'),
                _profileRow("INTERESTS", emp.interests.isNotEmpty ? emp.interests : '---'),
                const SizedBox(height: 24),''';

    content = content.replaceFirst(profileFind.trim(), profileReplace.trim());

    file.writeAsStringSync(content);
    print("Updated \$filePath");
  }
}
