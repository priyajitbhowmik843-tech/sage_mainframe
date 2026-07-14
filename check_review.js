const fs = require('fs');
const p = 'C:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/lib/screens/cofounder_dashboard.dart';
let t = fs.readFileSync(p, 'utf8');

const lines = t.split('\n');
lines.forEach((l, i) => {
  if (l.includes("'REVIEW'")) {
    console.log(i + 1, l.trim());
  }
});
