const fs = require('fs');

const ceo_path = "c:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/lib/screens/ceo_dashboard.dart";
const cfo_path = "c:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/lib/screens/cofounder_dashboard.dart";

const ceo_text = fs.readFileSync(ceo_path, "utf-8");
const cfo_text = fs.readFileSync(cfo_path, "utf-8");

const var_start = ceo_text.indexOf("  String _taskSubTab = 'CALENDAR';");
const meth_end = ceo_text.indexOf("  // ─── TAB 4: FINANCE");
if (var_start === -1 || meth_end === -1) {
    console.log("CEO bounds not found");
    process.exit(1);
}

const ceo_tasks_chunk = ceo_text.substring(var_start, meth_end);

const cfo_var_start = cfo_text.indexOf("  bool _showCFMyTasksOnly = false;");
const cfo_meth_end = cfo_text.indexOf("  // ─── TAB 4: FINANCE");
if (cfo_var_start === -1 || cfo_meth_end === -1) {
    console.log("CFO bounds not found");
    process.exit(1);
}

const new_cfo_text = cfo_text.substring(0, cfo_var_start) + "  String _cfChartTab = 'WEEKLY';\n" + ceo_tasks_chunk + cfo_text.substring(cfo_meth_end);

fs.writeFileSync(cfo_path, new_cfo_text, "utf-8");
console.log("Splice complete!");
