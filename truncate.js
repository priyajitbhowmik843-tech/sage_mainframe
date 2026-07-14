const fs=require('fs');
const files=[
  'C:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/lib/screens/ceo_dashboard.dart',
  'C:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/lib/screens/cofounder_dashboard.dart'
];
files.forEach(p=>{
  let t=fs.readFileSync(p,'utf8');
  let searchStr = "import 'executive_profile_dashboard.dart';";
  let firstIdx = t.indexOf(searchStr);
  let secondIdx = t.indexOf(searchStr, firstIdx + 10);
  if(secondIdx !== -1) {
    t = t.substring(0, secondIdx);
    fs.writeFileSync(p, t);
    console.log('Truncated '+p);
  }
});
