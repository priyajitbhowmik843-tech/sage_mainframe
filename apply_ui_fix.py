import os
import re

def fix_ceo_dashboard():
    path = "lib/screens/ceo_dashboard.dart"
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Update MyTasks filter (CEO)
    old_my_tasks = r"final myTasks = state\.tasks\.where\(\(t\) => t\.assignedTo == state\.activePersona\.id && !t\.isCompleted\)\.toList\(\);"
    new_my_tasks = r"final myTasks = state.tasks.where((t) => t.assignedTo == state.activePersona.id && !t.isCompleted && !(t.taskType ?? '').toLowerCase().contains('upload')).toList();"
    content = re.sub(old_my_tasks, new_my_tasks, content)

    # 2. Update PendingTasks filter (CEO)
    old_pending_tasks = r"final pendingTasks = state\.tasks\.where\(\(t\) \{\s*if \(t\.isCompleted\) return false;"
    new_pending_tasks = r"final pendingTasks = state.tasks.where((t) {\n      if (t.isCompleted) return false;\n      if ((t.taskType ?? '').toLowerCase().contains('upload')) return false;"
    content = re.sub(old_pending_tasks, new_pending_tasks, content)

    # 3. Update CEO MyTasks rendering
    old_builder = """              Builder(
                builder: (ctx) {
                  String dateLabel = '';
                  final typeStr = (t.taskType ?? '').toLowerCase();
                  if (typeStr == 'daily video' || typeStr == 'daily post') {
                    dateLabel = "Deadline: ${t.deadline.day}/${t.deadline.month}";
                  } else if (typeStr == 'session') {
                    dateLabel = "Session Date: ${t.deadline.day}/${t.deadline.month}";
                  } else if (typeStr == 'miscellaneous' || typeStr == 'misc') {
                    dateLabel = "Misc | Deadline: ${t.deadline.day}/${t.deadline.month}";
                  } else {
                    dateLabel = "${t.taskType ?? 'Task'} | Deadline: ${t.deadline.day}/${t.deadline.month}";
                  }
                  return Text(dateLabel, style: const TextStyle(color: SageColors.primary, fontSize: 11, fontWeight: FontWeight.bold));
                }
              ),"""
    
    new_builder = """              Builder(
                builder: (ctx) {
                  final typeStr = (t.taskType ?? '').toLowerCase();
                  Color typeColor = Colors.grey;
                  if (typeStr.contains('video')) typeColor = Colors.blue;
                  else if (typeStr.contains('post') || typeStr.contains('photo')) typeColor = Colors.orange;
                  else if (typeStr.contains('session') || typeStr.contains('meeting')) typeColor = Colors.purple;
                  else if (typeStr.contains('product')) typeColor = Colors.brown;
                  else if (typeStr.contains('upload')) typeColor = Colors.teal;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: typeColor)),
                        child: Text((t.taskType ?? 'Task').toUpperCase(), style: TextStyle(color: typeColor, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 4),
                      Text("Deadline: ${t.deadline.day}/${t.deadline.month}", style: const TextStyle(color: SageColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  );
                }
              ),"""
    
    if old_builder in content:
        content = content.replace(old_builder, new_builder)
    else:
        print("Could not find old_builder in CEO")

    # 4. Update CEO PendingTasks rendering
    old_pending_render = """              Text("${_getAssigneeName(t.assignedTo, state)} | ${t.deadline.day}/${t.deadline.month}", style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.bold)),"""
    new_pending_render = """              Builder(
                builder: (ctx) {
                  final typeStr = (t.taskType ?? '').toLowerCase();
                  Color typeColor = Colors.grey;
                  if (typeStr.contains('video')) typeColor = Colors.blue;
                  else if (typeStr.contains('post') || typeStr.contains('photo')) typeColor = Colors.orange;
                  else if (typeStr.contains('session') || typeStr.contains('meeting')) typeColor = Colors.purple;
                  else if (typeStr.contains('product')) typeColor = Colors.brown;
                  else if (typeStr.contains('upload')) typeColor = Colors.teal;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: typeColor)),
                        child: Text((t.taskType ?? 'Task').toUpperCase(), style: TextStyle(color: typeColor, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 4),
                      Text("${_getAssigneeName(t.assignedTo, state)} | ${t.deadline.day}/${t.deadline.month}", style: TextStyle(color: Colors.red.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  );
                }
              ),"""
    
    if old_pending_render in content:
        content = content.replace(old_pending_render, new_pending_render)
    else:
        print("Could not find old_pending_render in CEO")

    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Fixed CEO dashboard")

def fix_cfo_dashboard():
    path = "lib/screens/cofounder_dashboard.dart"
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Update MyTasks filter (CFO) and add sorting
    old_my_tasks = r"final myTasks = state\.tasks\.where\(\(t\) => t\.assignedTo == state\.activePersona\.id && !t\.isCompleted\)\.toList\(\);"
    new_my_tasks = r"final myTasks = state.tasks.where((t) => t.assignedTo == state.activePersona.id && !t.isCompleted && !(t.taskType ?? '').toLowerCase().contains('upload')).toList();\n    myTasks.sort((a, b) => a.deadline.compareTo(b.deadline));"
    content = re.sub(old_my_tasks, new_my_tasks, content)

    # 2. Update PendingTasks filter (CFO)
    old_pending_tasks = r"final pendingTasks = state\.tasks\.where\(\(t\) \{\s*if \(t\.isCompleted\) return false;"
    new_pending_tasks = r"final pendingTasks = state.tasks.where((t) {\n      if (t.isCompleted) return false;\n      if ((t.taskType ?? '').toLowerCase().contains('upload')) return false;"
    content = re.sub(old_pending_tasks, new_pending_tasks, content)
    
    if "}).toList();\n    \n    if (pendingTasks.isEmpty)" in content:
        content = content.replace(
            "}).toList();\n    \n    if (pendingTasks.isEmpty)",
            "}).toList();\n    pendingTasks.sort((a, b) => a.deadline.compareTo(b.deadline));\n    \n    if (pendingTasks.isEmpty)"
        )
    elif "}).toList();\n    if (pendingTasks.isEmpty)" in content:
        content = content.replace(
            "}).toList();\n    if (pendingTasks.isEmpty)",
            "}).toList();\n    pendingTasks.sort((a, b) => a.deadline.compareTo(b.deadline));\n    if (pendingTasks.isEmpty)"
        )

    # 3. Update CFO MyTasks rendering
    old_my_render = """              Text("${t.deadline.day}/${t.deadline.month}", style: const TextStyle(color: SageColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),"""
    new_my_render = """              Builder(
                builder: (ctx) {
                  final typeStr = (t.taskType ?? '').toLowerCase();
                  Color typeColor = Colors.grey;
                  if (typeStr.contains('video')) typeColor = Colors.blue;
                  else if (typeStr.contains('post') || typeStr.contains('photo')) typeColor = Colors.orange;
                  else if (typeStr.contains('session') || typeStr.contains('meeting')) typeColor = Colors.purple;
                  else if (typeStr.contains('product')) typeColor = Colors.brown;
                  else if (typeStr.contains('upload')) typeColor = Colors.teal;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: typeColor)),
                        child: Text((t.taskType ?? 'Task').toUpperCase(), style: TextStyle(color: typeColor, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 4),
                      Text("Deadline: ${t.deadline.day}/${t.deadline.month}", style: const TextStyle(color: SageColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  );
                }
              ),"""
    if old_my_render in content:
        content = content.replace(old_my_render, new_my_render)
    else:
        print("Could not find old_my_render in CFO")

    # 4. Update CFO PendingTasks rendering
    old_pending_render = """              Text("${_getAssigneeName(t.assignedTo, state)} | ${t.deadline.day}/${t.deadline.month}", style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.bold)),"""
    new_pending_render = """              Builder(
                builder: (ctx) {
                  final typeStr = (t.taskType ?? '').toLowerCase();
                  Color typeColor = Colors.grey;
                  if (typeStr.contains('video')) typeColor = Colors.blue;
                  else if (typeStr.contains('post') || typeStr.contains('photo')) typeColor = Colors.orange;
                  else if (typeStr.contains('session') || typeStr.contains('meeting')) typeColor = Colors.purple;
                  else if (typeStr.contains('product')) typeColor = Colors.brown;
                  else if (typeStr.contains('upload')) typeColor = Colors.teal;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: typeColor)),
                        child: Text((t.taskType ?? 'Task').toUpperCase(), style: TextStyle(color: typeColor, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 4),
                      Text("${_getAssigneeName(t.assignedTo, state)} | ${t.deadline.day}/${t.deadline.month}", style: TextStyle(color: Colors.red.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  );
                }
              ),"""
    
    if old_pending_render in content:
        content = content.replace(old_pending_render, new_pending_render)
    else:
        print("Could not find old_pending_render in CFO")

    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Fixed CFO dashboard")

if __name__ == "__main__":
    fix_ceo_dashboard()
    fix_cfo_dashboard()
