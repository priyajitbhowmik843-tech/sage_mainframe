const fs = require('fs');
let code = fs.readFileSync('lib/widgets/employee_metrics_panel.dart', 'utf8');

const newMethod = `  Widget _buildVideoEditorMetrics(BuildContext context) {
    List<Widget> children = [];
    
    if (!isVideoEditorPerVideo) {
      // Salaried: Show daily log
      final now = DateTime.now();
      final currentDay = now.day;
      
      List<Widget> dailyWidgets = [];
      for (int day = 1; day <= currentDay; day++) {
        final date = DateTime(now.year, now.month, day);
        final tasksForDay = state.tasks.where((t) => 
          t.assignedTo == employee.id &&
          t.taskType == 'video' &&
          t.isCompleted &&
          t.completedAt != null &&
          t.completedAt!.year == date.year &&
          t.completedAt!.month == date.month &&
          t.completedAt!.day == date.day
        ).toList();
        
        if (tasksForDay.isNotEmpty) {
          dailyWidgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('MMM dd, yyyy').format(date), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text("Completed: \${tasksForDay.length}", style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          );
        }
      }
      
      children.add(const Text("DAILY LOG", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)));
      children.add(const SizedBox(height: 8));
      if (dailyWidgets.isEmpty) {
        children.add(const Text("No completed videos this month.", style: const TextStyle(fontSize: 11)));
      } else {
        children.addAll(dailyWidgets);
      }
    } else {
      // Per Video: Show unpaid video edits with client name
      final unpaidEdits = state.tasks.where((t) => 
        t.assignedTo == employee.id &&
        t.taskType == 'video' &&
        t.isCompleted &&
        !t.isPaidToVideoEditor
      ).toList();
      
      children.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("UNPAID VIDEO EDITS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
            Text("\${unpaidEdits.length}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red)),
          ],
        )
      );
      children.add(const SizedBox(height: 8));
      
      if (unpaidEdits.isEmpty) {
        children.add(const Text("No unpaid videos.", style: const TextStyle(fontSize: 11)));
      } else {
        children.addAll(unpaidEdits.map((t) {
          final client = state.clients.where((c) => c.id == t.clientId).firstOrNull;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                const Icon(Icons.video_library, size: 12, color: Colors.black54),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(client?.name ?? 'Unknown Client', style: const TextStyle(fontSize: 9, color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Text(t.completedAt != null ? DateFormat('MMM dd').format(t.completedAt!) : '', style: const TextStyle(fontSize: 10, color: Colors.black54)),
              ],
            ),
          );
        }));
      }
    }

    return ExpansionTile(
      title: const Text("Video Editor Metrics", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: children,
    );
  }`;

let start = code.indexOf("  Widget _buildVideoEditorMetrics(BuildContext context) {");
let end = code.indexOf("  Widget _buildVideographerMetrics(BuildContext context) {");

if (start !== -1 && end !== -1) {
  code = code.substring(0, start) + newMethod + "\n\n" + code.substring(end);
  fs.writeFileSync('lib/widgets/employee_metrics_panel.dart', code, 'utf8');
  console.log("Successfully replaced _buildVideoEditorMetrics");
} else {
  console.log("Failed to find methods");
}
