const fs = require('fs');
const p = 'C:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/lib/screens/cofounder_dashboard.dart';
let t = fs.readFileSync(p, 'utf8');

// 1. Add preferredName display to Persona accordion (around line 1344, inside children)
t = t.replace(
  'Text("📞 ${p.phone.isNotEmpty ? p.phone : \\\'Not Provided\\\'}", style: const TextStyle(fontSize: 12, color: Colors.black87)),',
  'if (p.preferredName.isNotEmpty) Text("👤 Preferred Name: ${p.preferredName}", style: const TextStyle(fontSize: 12, color: Colors.black87)),\n                      Text("📞 ${p.phone.isNotEmpty ? p.phone : \\\'Not Provided\\\'}", style: const TextStyle(fontSize: 12, color: Colors.black87)),'
);

// 2. Add preferredName to Add Member Dialog
let addMemberDialogStart = t.indexOf('void _showAddMemberDialog(');
let addMemberDialogEnd = t.indexOf('Widget _buildClientSubTabBtn', addMemberDialogStart);
let addMemberDialog = t.substring(addMemberDialogStart, addMemberDialogEnd);

addMemberDialog = addMemberDialog.replace(
  'final TextEditingController nameCtrl = TextEditingController();',
  'final TextEditingController nameCtrl = TextEditingController();\n    final TextEditingController preferredNameCtrl = TextEditingController();'
);

addMemberDialog = addMemberDialog.replace(
  'SageTextField(controller: nameCtrl, label: "Full Name"),',
  'SageTextField(controller: nameCtrl, label: "Full Name"),\n                    const SizedBox(height: 10),\n                    SageTextField(controller: preferredNameCtrl, label: "Preferred Name (Optional)"),'
);

addMemberDialog = addMemberDialog.replace(
  'final res = context.read<AppState>().addEmployee(',
  'final res = context.read<AppState>().addEmployee(\n                        preferredName: preferredNameCtrl.text,'
);

t = t.substring(0, addMemberDialogStart) + addMemberDialog + t.substring(addMemberDialogEnd);

// 3. Add preferredName to Edit Employee Dialog
let editEmployeeDialogStart = t.indexOf('void _showEditEmployeeDialog(');
let editEmployeeDialogEnd = t.indexOf('void _showAddMemberDialog', editEmployeeDialogStart);
if (editEmployeeDialogEnd === -1) editEmployeeDialogEnd = t.indexOf('Widget _buildClientSubTabBtn', editEmployeeDialogStart);
let editEmployeeDialog = t.substring(editEmployeeDialogStart, editEmployeeDialogEnd);

editEmployeeDialog = editEmployeeDialog.replace(
  'final TextEditingController nameCtrl = TextEditingController(text: employee.name);',
  'final TextEditingController nameCtrl = TextEditingController(text: employee.name);\n    final TextEditingController preferredNameCtrl = TextEditingController(text: employee.preferredName);'
);

editEmployeeDialog = editEmployeeDialog.replace(
  'SageTextField(controller: nameCtrl, label: "Full Name"),',
  'SageTextField(controller: nameCtrl, label: "Full Name"),\n                    const SizedBox(height: 10),\n                    SageTextField(controller: preferredNameCtrl, label: "Preferred Name (Optional)"),'
);

editEmployeeDialog = editEmployeeDialog.replace(
  'name: nameCtrl.text,',
  'name: nameCtrl.text,\n                      preferredName: preferredNameCtrl.text,'
);

t = t.substring(0, editEmployeeDialogStart) + editEmployeeDialog + t.substring(editEmployeeDialogEnd);

fs.writeFileSync(p, t);
console.log('Updated cofounder_dashboard.dart personnel dialogs and persona view');
