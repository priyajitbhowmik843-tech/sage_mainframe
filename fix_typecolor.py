import re

files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cofounder_dashboard.dart'
]

for path in files:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find the places where the compilation errors were reported (where typeColor is used inside Text widgets but not defined in the scope)
    # The safest way is to just replace the text color styles back to the original in the exact lines that caused the error!
    
    # 1. Revert t.title text style where typeColor is not defined
    # We can just revert ALL occurrences of the text style in the file, and then ONLY add them back in the _buildTaskMyTasksSubTab and _buildTaskPendingSubTab.
    # Actually, the easiest is to just find `children: pendingTasks.map((t) {` inside _buildTaskReviewSubTab and add `Color typeColor = Colors.black;`
    
    # Find `children: pendingTasks.map((t) {\n          final submissionDateStr`
    content = re.sub(
        r'children: pendingTasks\.map\(\(t\) \{\s+final submissionDateStr =',
        r'children: pendingTasks.map((t) {\n          Color typeColor = Colors.black;\n          final submissionDateStr =',
        content
    )
    
    # Find `children: completedTasks.take(50).map((t) { // Limit to 50 for performance\n          return Container(`
    content = re.sub(
        r'children: completedTasks\.take\(50\)\.map\(\(t\) \{[^\n]*\s+return Container\(',
        r'children: completedTasks.take(50).map((t) {\n          Color typeColor = Colors.black;\n          return Container(',
        content
    )
    
    # Find `children: pendingTasks.map((t) {\n          return Container(` (for CFO)
    content = re.sub(
        r'children: pendingTasks\.map\(\(t\) \{\s+return Container\(',
        r'children: pendingTasks.map((t) {\n          Color typeColor = Colors.black;\n          return Container(',
        content
    )
    
    # There is also one more in CFO:
    # `children: completedTasks.take(50).map((t) {`
    # Already matched by the regex above!

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
