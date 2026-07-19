const fs = require('fs');
const files = [
  'lib/screens/employee_dashboard.dart',
  'lib/screens/dual_role_dashboard.dart',
  'lib/screens/graphics_editor_dashboard.dart',
  'lib/screens/videographer_dashboard.dart',
  'lib/screens/marketing_executive_dashboard.dart'
];

files.forEach(f => {
  let code = fs.readFileSync(f, 'utf8');
  code = code.replace(/return const TeamMembersView\(\)/g, "return TeamMembersView()");
  fs.writeFileSync(f, code, 'utf8');
});
console.log('Fixed const');
