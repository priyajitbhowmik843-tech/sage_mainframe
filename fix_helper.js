const fs = require('fs');
let code = fs.readFileSync('lib/screens/graphics_editor_dashboard.dart', 'utf8');

const helper = `  double _calculateDynamicDeduction(List<Task> myTasks) {
    final now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    if (now.year == 2026 && now.month == 7) {
      startOfMonth = DateTime(2026, 7, 20);
    }
    final today = DateTime(now.year, now.month, now.day);
    double dynamicDeduction = 0;
    
    for (DateTime d = startOfMonth; d.isBefore(today.add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
      final tasksForDay = myTasks.where((t) => 
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
        dynamicDeduction += (totalMissedForDay * 20.0);
      }
    }
    return dynamicDeduction;
  }
`;

code = code.replace(/class _GraphicsEditorDashboardState extends State<GraphicsEditorDashboard> \{/, `class _GraphicsEditorDashboardState extends State<GraphicsEditorDashboard> {\n${helper}`);

code = code.replace(/      final now = DateTime\.now\(\);\s+DateTime startOfMonth = DateTime\(now\.year, now\.month, 1\);\s+if \(now\.year == 2026 && now\.month == 7\) \{\s+startOfMonth = DateTime\(2026, 7, 20\);\s+\}\s+final today = DateTime\(now\.year, now\.month, now\.day\);\s+double dynamicDeduction = 0;\s+for \(DateTime d = startOfMonth; d\.isBefore\(today\.add\(const Duration\(days: 1\)\)\); d = d\.add\(const Duration\(days: 1\)\)\) \{\s+final tasksForDay = myTasks\.where\(\(t\) => \s+\(t\.taskType\?\.toLowerCase\(\) == 'design'\) &&\s+t\.deadline\.year == d\.year &&\s+t\.deadline\.month == d\.month &&\s+t\.deadline\.day == d\.day\s+\)\.toList\(\);\s+int assignedCount = tasksForDay\.length;\s+int shortfall = 5 - assignedCount;\s+if \(shortfall < 0\) shortfall = 0;\s+int rejectedOrManuallyMissed = tasksForDay\.where\(\(t\) => t\.isMissed == true \|\| t\.rejectedAt != null\)\.length;\s+int totalMissedForDay = shortfall \+ rejectedOrManuallyMissed;\s+if \(totalMissedForDay > 0\) \{\s+dynamicDeduction \+= \(totalMissedForDay \* 20\.0\);\s+\}\s+\}\s+final double deductionAmount = dynamicDeduction;/g, '      final double deductionAmount = _calculateDynamicDeduction(myTasks);');

code = code.replace(/final double amountUnpaid = numUnpaid \* emp\.perDesignRate;/g, 'final double amountUnpaid = numUnpaid * emp.perDesignRate;\n      final double deductionAmount = _calculateDynamicDeduction(myTasks);');

fs.writeFileSync('lib/screens/graphics_editor_dashboard.dart', code, 'utf8');
console.log('Fixed helper logic');
