import os

def process_file(filepath, prefix):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Replace button label logic if needed. 
    # _buildTaskSubTabBtn('TEAM') -> _buildTaskSubTabBtn('MY TASKS')
    content = content.replace("_buildTaskSubTabBtn('TEAM')", "_buildTaskSubTabBtn('MY TASKS')")
    
    # 2. Replace the condition
    # _taskSubTab == 'TEAM' -> _taskSubTab == 'MY TASKS'
    # And the function call _buildTaskTeamSubTab() -> _buildTaskMyTasksSubTab('CEO'/'COF')
    content = content.replace("if (_taskSubTab == 'TEAM') _buildTaskTeamSubTab()", f"if (_taskSubTab == 'MY TASKS') _buildTaskMyTasksSubTab('{prefix}')")
    
    # 3. Replace the _buildTaskTeamSubTab method with _buildTaskMyTasksSubTab
    # Need to find the start of _buildTaskTeamSubTab() and replace the whole block until _buildTaskPendingSubTab()
    start_idx = content.find("  Widget _buildTaskTeamSubTab() {")
    end_idx = content.find("  Widget _buildTaskPendingSubTab() {")
    
    if start_idx != -1 and end_idx != -1:
        new_method = f"""  Widget _buildTaskMyTasksSubTab(String personaPrefix) {{
    final state = context.watch<AppState>();
    final myTasks = state.tasks.where((t) => t.assignedTo.contains(personaPrefix) && !t.isCompleted).toList();
    
    if (myTasks.isEmpty) {{
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: const Center(
          child: Text(
            'NO PENDING TASKS FOR YOU',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: SageColors.onSurfaceVariant),
          ),
        ),
      );
    }}
    
    return Column(
      children: myTasks.map((t) {{
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black, width: 1.5)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
              Text("${{t.deadline.day}}/${{t.deadline.month}}", style: const TextStyle(color: SageColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }}).toList(),
    );
  }}

"""
        content = content[:start_idx] + new_method + content[end_idx:]

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)

base_path = "c:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/lib/screens"
process_file(os.path.join(base_path, "ceo_dashboard.dart"), "CEO")
process_file(os.path.join(base_path, "cofounder_dashboard.dart"), "COF")

print("Files updated successfully")
