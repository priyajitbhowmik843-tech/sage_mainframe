const fs = require('fs');
let code = fs.readFileSync('lib/screens/graphics_editor_dashboard.dart', 'utf8');

const target = `    final int completedCount = completedDesigns.length;
    final double deductionAmount = emp.pendingPayDeduction;
    
    final numPaid = completedDesigns.where((t) => t.isPaymentAcknowledgedByGraphicsEditor).length;`;

const replacement = `    final int completedCount = completedDesigns.length;
    
    // Dynamically calculate deductions for the current month
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
        t.assignedDate != null &&
        t.assignedDate!.year == d.year &&
        t.assignedDate!.month == d.month &&
        t.assignedDate!.day == d.day
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
    final double deductionAmount = dynamicDeduction;
    
    final numPaid = completedDesigns.where((t) => t.isPaymentAcknowledgedByGraphicsEditor).length;`;

if (code.includes('emp.pendingPayDeduction')) {
    code = code.replace(target, replacement);
    fs.writeFileSync('lib/screens/graphics_editor_dashboard.dart', code, 'utf8');
    console.log('Fixed deductions');
} else {
    console.log('Target not found');
}
