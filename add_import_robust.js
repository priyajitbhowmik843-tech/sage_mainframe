const fs=require('fs');
const p='C:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/lib/screens/videographer_dashboard.dart';
let t=fs.readFileSync(p,'utf8');
if(!t.includes("import 'package:sage_mainframe/widgets/common_widgets.dart';")){
  t = "import 'package:sage_mainframe/widgets/common_widgets.dart';\n" + t;
  fs.writeFileSync(p,t);
  console.log('Added common_widgets import');
} else {
  console.log('already has import');
}
