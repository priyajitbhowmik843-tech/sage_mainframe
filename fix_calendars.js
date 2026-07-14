const fs = require('fs');

const files = [
  { path: 'lib/screens/ceo_dashboard.dart', dateVar: '_selectedCalendarDate' },
  { path: 'lib/screens/cofounder_dashboard.dart', dateVar: '_selectedCalendarDate' },
  { path: 'lib/screens/videographer_dashboard.dart', dateVar: '_selectedDate' },
  { path: 'lib/screens/employee_dashboard.dart', dateVar: '_selectedDate' }
];

files.forEach(f => {
  let p = 'C:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/' + f.path;
  if (fs.existsSync(p)) {
    let t = fs.readFileSync(p, 'utf8');

    // If it already has a root GestureDetector, modify it
    if (t.includes('child: GestureDetector(\n        onTap: () {\n          FocusScope.of(context).unfocus();\n        },')) {
      t = t.replace(
        'child: GestureDetector(\n        onTap: () {\n          FocusScope.of(context).unfocus();\n        },',
        `child: GestureDetector(\n        behavior: HitTestBehavior.opaque,\n        onTap: () {\n          FocusScope.of(context).unfocus();\n          if (${f.dateVar} != null) setState(() => ${f.dateVar} = null);\n        },`
      );
    } 
    // Otherwise add the GestureDetector
    else if (t.includes('      child: Scaffold(')) {
      t = t.replace(
        '      child: Scaffold(',
        `      child: GestureDetector(\n        behavior: HitTestBehavior.opaque,\n        onTap: () {\n          FocusScope.of(context).unfocus();\n          if (${f.dateVar} != null) setState(() => ${f.dateVar} = null);\n        },\n        child: Scaffold(`
      );
      // Now add a closing bracket for GestureDetector before the end of WillPopScope
      // Let's just find the end of WillPopScope which is typically the end of the build method
      // Actually, all these dashboard build methods return WillPopScope
      t = t.replace(
        '    );\n  }\n\n  Widget _build',
        '      ),\n    );\n  }\n\n  Widget _build'
      );
      // Wait, let's make it robust by adding `)` at the end of the build method
    }

    fs.writeFileSync(p, t);
    console.log('updated ' + f.path);
  }
});
