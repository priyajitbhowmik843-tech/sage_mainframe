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
  if (!code.includes("team_members_view.dart")) {
    code = code.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:sage_mainframe/widgets/team_members_view.dart';");
    fs.writeFileSync(f, code, 'utf8');
  }
});
console.log('Fixed imports');
