const fs = require('fs');
let code = fs.readFileSync('lib/screens/graphics_editor_dashboard.dart', 'utf8');

code = code.replace(/t\.assignedDate/g, 't.deadline');
// deadline is not nullable in Task, so remove ! if there's any
code = code.replace(/t\.deadline!\.year/g, 't.deadline.year');
code = code.replace(/t\.deadline!\.month/g, 't.deadline.month');
code = code.replace(/t\.deadline!\.day/g, 't.deadline.day');
code = code.replace(/t\.deadline != null &&/g, '');

fs.writeFileSync('lib/screens/graphics_editor_dashboard.dart', code, 'utf8');
console.log('Fixed assignedDate to deadline');
