import os

ceo_path = "c:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/lib/screens/ceo_dashboard.dart"
cfo_path = "c:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/lib/screens/cofounder_dashboard.dart"

with open(ceo_path, "r", encoding="utf-8") as f:
    ceo_text = f.read()

with open(cfo_path, "r", encoding="utf-8") as f:
    cfo_text = f.read()

# Get CEO chunk
var_start = ceo_text.find("  String _taskSubTab = 'CALENDAR';")
meth_end = ceo_text.find("  // ─── TAB 4: FINANCE")
if var_start == -1 or meth_end == -1:
    print("CEO bounds not found")
    exit(1)

ceo_tasks_chunk = ceo_text[var_start:meth_end]

# Get CFO chunk
cfo_var_start = cfo_text.find("  bool _showCFMyTasksOnly = false;")
cfo_meth_end = cfo_text.find("  // ─── TAB 4: FINANCE")
if cfo_var_start == -1 or cfo_meth_end == -1:
    print("CFO bounds not found")
    exit(1)

new_cfo_text = cfo_text[:cfo_var_start] + "  String _cfChartTab = 'WEEKLY';\n" + ceo_tasks_chunk + cfo_text[cfo_meth_end:]

with open(cfo_path, "w", encoding="utf-8") as f:
    f.write(new_cfo_text)

print("Splice complete!")
