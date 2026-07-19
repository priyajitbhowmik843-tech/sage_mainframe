const fs = require('fs');

const missedLogic = `int rejectedOrManuallyMissed = tasksForDay.where((t) {
          if (t.isMissed == true || t.rejectedAt != null) return true;
          final deadlinePlus24 = t.deadline.add(const Duration(hours: 24));
          if (t.submittedAt != null) {
            return t.submittedAt!.isAfter(deadlinePlus24);
          } else {
            if (t.isCompleted) return false;
            return DateTime.now().isAfter(deadlinePlus24);
          }
        }).length;`;

function fixMissed(filePath) {
    let code = fs.readFileSync(filePath, 'utf8');
    
    code = code.replace(/int rejectedOrManuallyMissed = tasksForDay\.where\(\(t\) => t\.isMissed == true \|\| t\.rejectedAt != null\)\.length;/g, missedLogic);
    
    fs.writeFileSync(filePath, code, 'utf8');
    console.log(`Fixed missed logic in ${filePath}`);
}

fixMissed('lib/widgets/employee_metrics_panel.dart');
fixMissed('lib/screens/graphics_editor_dashboard.dart');
