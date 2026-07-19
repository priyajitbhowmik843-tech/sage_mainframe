const fs = require('fs');

function addTeamImport(code) {
  if (!code.includes("team_members_view.dart")) {
    return code.replace("import '../widgets/terminal_panel.dart';", "import '../widgets/terminal_panel.dart';\nimport '../widgets/team_members_view.dart';");
  }
  return code;
}

// 1. employee_dashboard.dart
let empCode = fs.readFileSync('lib/screens/employee_dashboard.dart', 'utf8');
empCode = addTeamImport(empCode);
empCode = empCode.replace("_navIcon(3, Icons.person_outline, Icons.person),", "_navIcon(3, Icons.person_outline, Icons.person),\n                      _navIcon(4, Icons.group_outlined, Icons.group),");
empCode = empCode.replace("case 3: return _buildProfileTab(context, state, persona);", "case 3: return _buildProfileTab(context, state, persona);\n      case 4: return const TeamMembersView();");
fs.writeFileSync('lib/screens/employee_dashboard.dart', empCode, 'utf8');

// 2. dual_role_dashboard.dart
let dualCode = fs.readFileSync('lib/screens/dual_role_dashboard.dart', 'utf8');
dualCode = addTeamImport(dualCode);
dualCode = dualCode.replace("_navIcon(3, Icons.person_outline, Icons.person),", "_navIcon(3, Icons.person_outline, Icons.person),\n                      _navIcon(4, Icons.group_outlined, Icons.group),");
dualCode = dualCode.replace("case 3: return _buildProfileTab(context, state, persona);", "case 3: return _buildProfileTab(context, state, persona);\n      case 4: return const TeamMembersView();");
fs.writeFileSync('lib/screens/dual_role_dashboard.dart', dualCode, 'utf8');

// 3. graphics_editor_dashboard.dart
let geCode = fs.readFileSync('lib/screens/graphics_editor_dashboard.dart', 'utf8');
geCode = addTeamImport(geCode);
geCode = geCode.replace("_navIcon(2, Icons.person_outline, Icons.person),", "_navIcon(2, Icons.person_outline, Icons.person),\n                  _navIcon(3, Icons.group_outlined, Icons.group),");
geCode = geCode.replace("case 2: return _buildProfileTab(context, state, persona);", "case 2: return _buildProfileTab(context, state, persona);\n      case 3: return const TeamMembersView();");
fs.writeFileSync('lib/screens/graphics_editor_dashboard.dart', geCode, 'utf8');

// 4. videographer_dashboard.dart
let vgCode = fs.readFileSync('lib/screens/videographer_dashboard.dart', 'utf8');
vgCode = addTeamImport(vgCode);
vgCode = vgCode.replace("_navIcon(2, Icons.person_outline, Icons.person),", "_navIcon(2, Icons.person_outline, Icons.person),\n                  _navIcon(3, Icons.group_outlined, Icons.group),");
vgCode = vgCode.replace("case 2: return _buildProfileTab(context, state, persona);", "case 2: return _buildProfileTab(context, state, persona);\n      case 3: return const TeamMembersView();");
fs.writeFileSync('lib/screens/videographer_dashboard.dart', vgCode, 'utf8');

// 5. marketing_executive_dashboard.dart
let meCode = fs.readFileSync('lib/screens/marketing_executive_dashboard.dart', 'utf8');
meCode = addTeamImport(meCode);
meCode = meCode.replace("_buildBottomIcon(2, Icons.person_outline, Icons.person),", "_buildBottomIcon(2, Icons.person_outline, Icons.person),\n                    _buildBottomIcon(3, Icons.group_outlined, Icons.group),");
meCode = meCode.replace("case 2: return _buildProfileTab(context, state, emp);", "case 2: return _buildProfileTab(context, state, emp);\n      case 3: return const TeamMembersView();");
meCode = meCode.replace("if (_tab == 2) title = \"PROFILE\";", "if (_tab == 2) title = \"PROFILE\";\n    if (_tab == 3) title = \"TEAM\";");
fs.writeFileSync('lib/screens/marketing_executive_dashboard.dart', meCode, 'utf8');

console.log('Patched all 5 dashboards');
