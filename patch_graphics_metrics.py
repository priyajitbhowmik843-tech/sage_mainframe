import re

filepath = 'lib/widgets/employee_metrics_panel.dart'

with open(filepath, 'r', encoding='utf-8') as f:
    code = f.read()

# Add cloud_firestore if missing
if "import 'package:cloud_firestore/cloud_firestore.dart';" not in code:
    code = code.replace("import 'package:provider/provider.dart';", "import 'package:provider/provider.dart';\nimport 'package:cloud_firestore/cloud_firestore.dart';")

# Identify the _buildGraphicsEditorMetrics block
# It starts at: Widget _buildGraphicsEditorMetrics(BuildContext context) {
# And ends at the next Widget _...

pattern = r"Widget _buildGraphicsEditorMetrics\(BuildContext context\) \{.*?(?=^\s*Widget _buildLegacyMetrics|\Z)"
# Wait, it might be followed by _buildVideoEditorMetrics instead of _buildLegacyMetrics
pattern = r"Widget _buildGraphicsEditorMetrics\(BuildContext context\) \{.*?(?=^\s*Widget _build)"

replacement = """Widget _buildGraphicsEditorMetrics(BuildContext context) {
    final now = DateTime.now();
    final actualStart = DateTime(2026, 7, 20);
    
    List<Widget> dailyWidgets = [];
    double totalDeduction = 0;
    
    final today = DateTime(now.year, now.month, now.day);
    
    for (DateTime d = actualStart; d.isBefore(today.add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
      final tasksForDay = state.tasks.where((t) => 
        t.assignedTo == employee.id &&
        (t.taskType?.toLowerCase() == 'design') &&
        t.deadline.year == d.year &&
        t.deadline.month == d.month &&
        t.deadline.day == d.day
      ).toList();
      
      int assignedCount = tasksForDay.length;
      int shortfall = 5 - assignedCount;
      if (shortfall < 0) shortfall = 0;
      
      int rejectedOrManuallyMissed = tasksForDay.where((t) => t.isMissed == true || t.rejectedAt != null).length;
      
      int totalMissedForDay = shortfall + rejectedOrManuallyMissed;
      if (totalMissedForDay > 0) {
        double deductionForDay = totalMissedForDay * 20.0;
        totalDeduction += deductionForDay;
        
        dailyWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('MMM dd, yyyy').format(d), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Text("Missed: $totalMissedForDay (-\u20B9${deductionForDay.toStringAsFixed(0)})", style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        );
      }
    }

    return ExpansionTile(
      title: const Text("Graphics Editor Metrics", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("TOTAL DEDUCTION", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
            Text("-\u20B9${totalDeduction.toStringAsFixed(0)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        ...dailyWidgets,
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: actualStart,
              lastDate: now,
            );
            if (selectedDate != null) {
              _showDeductionDialog(context, selectedDate);
            }
          },
          child: const Text("Add Deduction"),
        )
      ],
    );
  }

  void _showDeductionDialog(BuildContext context, DateTime selectedDate) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final tasks = state.tasks.where((t) => 
              t.assignedTo == employee.id &&
              (t.taskType?.toLowerCase() == 'design') &&
              t.deadline.year == selectedDate.year &&
              t.deadline.month == selectedDate.month &&
              t.deadline.day == selectedDate.day
            ).toList();

            return AlertDialog(
              title: Text("Tasks for ${DateFormat('MMM dd, yyyy').format(selectedDate)}"),
              content: SizedBox(
                width: double.maxFinite,
                child: tasks.isEmpty 
                  ? const Text("No tasks assigned for this date.") 
                  : ListView.builder(
                  shrinkWrap: true,
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final t = tasks[index];
                    return CheckboxListTile(
                      title: Text(t.title),
                      subtitle: Text(t.rejectedAt != null ? "Rejected by CEO" : "Assigned"),
                      value: t.isMissed || t.rejectedAt != null,
                      onChanged: t.rejectedAt != null ? null : (val) {
                        FirebaseFirestore.instance.collection('tasks').doc(t.id).update({
                          'isMissed': val == true
                        });
                        setState(() {
                           t.isMissed = val == true; 
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
              ],
            );
          }
        );
      }
    );
  }

"""

new_code = re.sub(r"Widget _buildGraphicsEditorMetrics\(BuildContext context\) \{.*?(?=^\s*Widget _build)", replacement, code, flags=re.MULTILINE | re.DOTALL)

if new_code == code:
    print("NO MATCH FOUND")
else:
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_code)
    print("PATCH SUCCESSFUL")
