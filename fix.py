import os

files_to_edit = [
    'lib/screens/employee_dashboard.dart',
    'lib/screens/marketing_executive_dashboard.dart',
    'lib/screens/videographer_dashboard.dart'
]

ui_insert = '''
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
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: selectedWorkStyle,
                        decoration: const InputDecoration(labelText: "Work Style Preference"),
                        items: ['Independent thinker', 'Team collaborator', 'Detail-oriented', 'Fast executor', 'Strategic planner'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => selectedWorkStyle = v ?? 'Independent thinker',
                      ),
                      const SizedBox(height: 10),
                      SageTextField(controller: interestsCtrl, label: "Interests / Hobbies"),
                      const SizedBox(height: 20),
                      const Text("CHOOSE AVATAR", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),'''

ui_find = '''
                      SageTextField(controller: emailCtrl, label: "Email"),
                      const SizedBox(height: 20),
                      const Text("CHOOSE AVATAR", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),'''

for file in files_to_edit:
    if not os.path.exists(file): continue
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Add variables to start of _showEditPersonalDetailsDialog if not there
    if 'final prefNameCtrl =' not in content:
        content = content.replace(
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
        )

    # UI insertion
    content = content.replace(ui_find.strip(), ui_insert.strip())

    # Update call
    content = content.replace(
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
    )

    # Profile row additions
    profile_find = '''_profileRow("EMAIL", emp.email.isNotEmpty ? emp.email : '---'),
                const SizedBox(height: 24),'''
    
    profile_replace = '''_profileRow("EMAIL", emp.email.isNotEmpty ? emp.email : '---'),
                _profileRow("PREFERRED NAME", emp.preferredName.isNotEmpty ? emp.preferredName : '---'),
                _profileRow("EMERGENCY", emp.emergencyContact.isNotEmpty ? emp.emergencyContact : '---'),
                _profileRow("BIO", emp.professionalBio.isNotEmpty ? emp.professionalBio : '---'),
                _profileRow("WORK LOCATION", emp.workLocation.isNotEmpty ? emp.workLocation : '---'),
                _profileRow("WORK STYLE", emp.workStylePreference.isNotEmpty ? emp.workStylePreference : '---'),
                _profileRow("INTERESTS", emp.interests.isNotEmpty ? emp.interests : '---'),
                const SizedBox(height: 24),'''
    
    content = content.replace(profile_find.strip(), profile_replace.strip())

    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"Updated {file}")
