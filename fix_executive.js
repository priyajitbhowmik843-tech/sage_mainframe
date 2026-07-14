const fs = require('fs');
const p = 'C:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/lib/screens/executive_profile_dashboard.dart';
let t = fs.readFileSync(p, 'utf8');

// 1. Fix Tab Names
t = t.replace(
  "Tab(icon: Icon(Icons.folder_special), text: 'Ledger Archives'),",
  "Tab(icon: Icon(Icons.folder_special), text: 'Ledger'),"
);
t = t.replace(
  "Tab(icon: Icon(Icons.notifications_paused), text: 'Notification Archives'),",
  "Tab(icon: Icon(Icons.notifications_paused), text: 'Notifs'),"
);

// 2. Change TextFormField to SageTextField
t = t.replace(
  "TextFormField(\n                    controller: _nameCtrl,\n                    decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.badge, color: Colors.black)),\n                  ),",
  "SageTextField(\n                    controller: _nameCtrl,\n                    label: 'Full Name',\n                  ),"
);
t = t.replace(
  "TextFormField(\n                    controller: _prefNameCtrl,\n                    decoration: const InputDecoration(labelText: 'Preferred Name', prefixIcon: Icon(Icons.person, color: Colors.black)),\n                  ),",
  "SageTextField(\n                    controller: _prefNameCtrl,\n                    label: 'Preferred Name',\n                  ),"
);
t = t.replace(
  "TextFormField(\n                    controller: _phoneCtrl,\n                    decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone, color: Colors.black)),\n                  ),",
  "SageTextField(\n                    controller: _phoneCtrl,\n                    label: 'Phone Number',\n                  ),"
);
t = t.replace(
  "TextFormField(\n                    controller: _emailCtrl,\n                    decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email, color: Colors.black)),\n                  ),",
  "SageTextField(\n                    controller: _emailCtrl,\n                    label: 'Email Address',\n                  ),"
);
t = t.replace(
  "TextFormField(\n                    controller: _addressCtrl,\n                    decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.home, color: Colors.black)),\n                    maxLines: 2,\n                  ),",
  "SageTextField(\n                    controller: _addressCtrl,\n                    label: 'Address',\n                    maxLines: 2,\n                  ),"
);
t = t.replace(
  "TextFormField(\n                          controller: _dobCtrl,\n                          decoration: const InputDecoration(labelText: 'Date of Birth', prefixIcon: Icon(Icons.calendar_today, color: Colors.black)),\n                        ),",
  "SageTextField(\n                          controller: _dobCtrl,\n                          label: 'Date of Birth',\n                        ),"
);
t = t.replace(
  "TextFormField(\n                          controller: _genderCtrl,\n                          decoration: const InputDecoration(labelText: 'Gender', prefixIcon: Icon(Icons.person_outline, color: Colors.black)),\n                        ),",
  "SageTextField(\n                          controller: _genderCtrl,\n                          label: 'Gender',\n                        ),"
);
t = t.replace(
  "TextFormField(\n                    controller: _emergencyCtrl,\n                    decoration: const InputDecoration(labelText: 'Emergency Contact', prefixIcon: Icon(Icons.warning, color: Colors.black)),\n                  ),",
  "SageTextField(\n                    controller: _emergencyCtrl,\n                    label: 'Emergency Contact',\n                  ),"
);
t = t.replace(
  "TextFormField(\n                    controller: _bioCtrl,\n                    decoration: const InputDecoration(labelText: 'Professional Bio', prefixIcon: Icon(Icons.description, color: Colors.black)),\n                    maxLines: 3,\n                  ),",
  "SageTextField(\n                    controller: _bioCtrl,\n                    label: 'Professional Bio',\n                    maxLines: 3,\n                  ),"
);
t = t.replace(
  "TextFormField(\n                    controller: _interestsCtrl,\n                    decoration: const InputDecoration(labelText: 'Interests / Hobbies', prefixIcon: Icon(Icons.star, color: Colors.black)),\n                  ),",
  "SageTextField(\n                    controller: _interestsCtrl,\n                    label: 'Interests / Hobbies',\n                  ),"
);

// 3. Update Scaffold Background
t = t.replace(
  "return Scaffold(\n      appBar: AppBar(",
  "return Scaffold(\n      backgroundColor: SageColors.background,\n      appBar: AppBar("
);

fs.writeFileSync(p, t);
console.log('Updated executive_profile_dashboard.dart');
