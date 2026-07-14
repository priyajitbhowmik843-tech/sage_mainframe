import re

def main():
    file_path = 'lib/screens/cofounder_dashboard.dart'
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Replace mangled characters
    # A'A,AAAA?sAA,A?AAA,A,AA'A,AAAA?sAA,A?AAA,A,A Session Booking UI A'A,AAAA?sAA,A?AAA,A,AA'A,AAAA?sAA,A?AAA,A,A
    content = re.sub(r'// [^a-zA-Z0-9]+ Session Booking UI [^a-zA-Z0-9\n]+', '// --- Session Booking UI ---', content)
    
    # "A'A,AA?A,AA?sA,A Max 3 clients already booked on this date."
    content = re.sub(r'"[^a-zA-Z0-9"]+ Max 3 clients already booked on this date."', r'"⚠️ Max 3 clients already booked on this date."', content)

    # "${c.name} A'A... ?${c.sessionRate...
    content = re.sub(r'Text\("\$\{c\.name\} [^a-zA-Z0-9"]+\$\{c\.sessionRate', r'Text("${c.name} - ₹${c.sessionRate', content)

    # 'Session A'A... $clientName'
    content = re.sub(r"'Session [^a-zA-Z0-9']+ \$clientName'", r"'Session - $clientName'", content)

    # Text("${_getAssigneeName(t.assignedTo, state)} A'A... ${t.deadline.day}
    content = re.sub(r'Text\("\$\{\_getAssigneeName\(t\.assignedTo, state\)\} [^a-zA-Z0-9"]+ \$\{t\.deadline\.day\}', r'Text("${_getAssigneeName(t.assignedTo, state)} | ${t.deadline.day}', content)

    # // A'A... TAB 4: FINANCE A'A...
    content = re.sub(r'// [^a-zA-Z0-9]+ TAB 4: FINANCE [^a-zA-Z0-9\n]+', '// --- --- --- --- TAB 4: FINANCE --- --- --- --- ---', content)

    # "Monthly Payable (A'A...)"
    content = re.sub(r'"Monthly Payable \([^a-zA-Z0-9]+\)"', r'"Monthly Payable (₹)"', content)

    # "Session Rate (A'A...)"
    content = re.sub(r'"Session Rate \([^a-zA-Z0-9]+\)"', r'"Session Rate (₹)"', content)


    # 2. Update _buildTaskSubTabBtn
    old_btn = r"""  Widget _buildTaskSubTabBtn\(String title\) \{
    final isSelected = _taskSubTab == title;
    return GestureDetector\(
      onTap: \(\) => setState\(\(\) => _taskSubTab = title\),
      child: Container\(
        padding: const EdgeInsets\.symmetric\(horizontal: 16, vertical: 8\),
        decoration: BoxDecoration\(
          color: isSelected \? Colors\.black : Colors\.white,
          borderRadius: BorderRadius\.circular\(12\),
          border: Border\.all\(color: Colors\.black, width: 1\.5\),
        \),
        child: Text\(
          title,
          textAlign: TextAlign\.center,
          style: TextStyle\(
            fontSize: 10,
            fontWeight: FontWeight\.bold,
            color: isSelected \? Colors\.white : Colors\.black,
          \),
        \),
      \),
    \);
  \}"""

    new_btn = """  Widget _buildTaskSubTabBtn(String title, {int badgeCount = 0}) {
    final isSelected = _taskSubTab == title;
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );

    return GestureDetector(
      onTap: () => setState(() => _taskSubTab = title),
      child: badgeCount > 0
          ? Badge(
              label: Text(badgeCount.toString()),
              child: child,
            )
          : child,
    );
  }"""
    content = re.sub(old_btn, new_btn, content)

    # 3. Update _buildTasksTab
    old_tabs = r"""  Widget _buildTasksTab\(\) \{
    return Column\(
      crossAxisAlignment: CrossAxisAlignment\.stretch,
      children: \[
        SingleChildScrollView\(
          scrollDirection: Axis\.horizontal,
          child: Row\(
            mainAxisAlignment: MainAxisAlignment\.center,
            children: \[
              _buildTaskSubTabBtn\('CALENDAR'\),
              const SizedBox\(width: 4\),
              _buildTaskSubTabBtn\('MY TASKS'\),
              const SizedBox\(width: 4\),
              _buildTaskSubTabBtn\('PENDING'\),
              const SizedBox\(width: 4\),
              _buildTaskSubTabBtn\('COMPLETED'\),
            \],
          \),
        \),
        const SizedBox\(height: 16\),
        if \(_taskSubTab == 'CALENDAR'\) _buildTaskCalendarSubTab\(\),
        if \(_taskSubTab == 'MY TASKS'\) _buildTaskMyTasksSubTab\('CEO'\),
        if \(_taskSubTab == 'PENDING'\) _buildTaskPendingSubTab\(\),
        if \(_taskSubTab == 'COMPLETED'\) _buildTaskCompletedSubTab\(\),
      \],
    \);
  \}"""

    new_tabs = """  Widget _buildTasksTab() {
    final state = context.watch<AppState>();
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    final int pendingCount = state.tasks.where((t) {
      if (t.isCompleted) return false;
      final isToday = t.deadline.year == now.year && t.deadline.month == now.month && t.deadline.day == now.day;
      final isOverdue = t.deadline.isBefore(todayStart);
      return isToday || isOverdue;
    }).length;
    
    final int myTasksCount = state.tasks.where((t) => t.assignedTo == state.activePersona.id && !t.isCompleted).length;
    final int reviewCount = state.tasks.where((t) => (t.isSubmitted && !t.isCompleted) || t.isPostponeRequested).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTaskSubTabBtn('CALENDAR'),
              const SizedBox(width: 4),
              _buildTaskSubTabBtn('MY TASKS', badgeCount: myTasksCount),
              const SizedBox(width: 4),
              _buildTaskSubTabBtn('PENDING', badgeCount: pendingCount),
              const SizedBox(width: 4),
              _buildTaskSubTabBtn('REVIEW', badgeCount: reviewCount),
              const SizedBox(width: 4),
              _buildTaskSubTabBtn('COMPLETED'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_taskSubTab == 'CALENDAR') _buildTaskCalendarSubTab(),
        if (_taskSubTab == 'MY TASKS') _buildTaskMyTasksSubTab('CFO'),
        if (_taskSubTab == 'PENDING') _buildTaskPendingSubTab(),
        if (_taskSubTab == 'REVIEW') _buildTaskReviewSubTab(),
        if (_taskSubTab == 'COMPLETED') _buildTaskCompletedSubTab(),
      ],
    );
  }"""
    content = re.sub(old_tabs, new_tabs, content)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Done")

if __name__ == '__main__':
    main()
