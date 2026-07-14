const fs=require('fs');
const p='C:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/lib/widgets/common_widgets.dart';
let t=fs.readFileSync(p,'utf8');
t=t.replace('export " sage_calendar.dart;', "export 'sage_calendar.dart';");
fs.writeFileSync(p,t);
console.log('Fixed export in common_widgets.dart');
