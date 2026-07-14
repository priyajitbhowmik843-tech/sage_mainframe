const fs = require('fs');

const ceoFile = "c:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/lib/screens/ceo_dashboard.dart";
const cfoFile = "c:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/lib/screens/cofounder_dashboard.dart";
const cfoRecFile = "c:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/lib/screens/cofounder_dashboard_recovered.dart";

const cfoText = fs.readFileSync(cfoFile, 'utf-8');
const cfoRecText = fs.readFileSync(cfoRecFile, 'utf-8');

// Get _buildTasksTab from cfoText
const tasksTabStart = cfoText.indexOf("  String _taskSubTab = 'CALENDAR';");
const financeTabStart = cfoText.indexOf("  // ─── TAB 4: FINANCE");
let tasksTabStr = cfoText.substring(tasksTabStart, financeTabStart);

// Get the rest from cfoRecText
const cfoRecFinanceStart = cfoRecText.indexOf("  // ─── TAB 4: FINANCE");
let restStr = cfoRecText.substring(cfoRecFinanceStart);

// Replace _CofounderDashboardState with _CeoDashboardState in restStr
restStr = restStr.replace(/_CofounderDashboardState/g, "_CeoDashboardState");
restStr = restStr.replace(/_cfChartTab/g, "_financeChartTab");

// Append to ceoFile
let ceoText = fs.readFileSync(ceoFile, 'utf-8');
// remove trailing newline if any
if (ceoText.endsWith("\n")) {
    ceoText = ceoText.substring(0, ceoText.length - 1);
}

fs.writeFileSync(ceoFile, ceoText + "\n\n" + tasksTabStr + "\n" + restStr, 'utf-8');
console.log("ceo_dashboard.dart recovered!");
