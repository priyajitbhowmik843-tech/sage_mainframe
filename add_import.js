const fs=require('fs');
const p='C:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/lib/screens/videographer_dashboard.dart';
let t=fs.readFileSync(p,'utf8');
if(!t.includes('package:sage_mainframe/widgets/common_widgets.dart')){
  t=t.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:sage_mainframe/widgets/common_widgets.dart';");
  fs.writeFileSync(p,t);
  console.log('Added common_widgets import');
}
