import re

with open('lib/state/app_state.dart', 'r', encoding='utf-8') as f:
    content = f.read()

pattern = r'''  Future<String\?> assignTask\(\{
    required String title,
    required String description,
    required String assignedTo,
    required DateTime deadline,
    String\? clientId,
    String\? taskType,
    String\? instructions,
    List<String> sessionClientIds = const \[\],
    bool isApprovedByVideographer = false,
  \}\) async \{
    if \(title\.trim\(\)\.isEmpty\) return 'ERROR: Task title is required\.';

    final newTask = Task\(
      id: '', // Firestore generates this
      title: title,
      description: description,
      assignedTo: assignedTo,
      assignedBy: _activePersona\.id,
      deadline: deadline,
      clientId: clientId,
      taskType: taskType,
      instructions: instructions,
      sessionClientIds: sessionClientIds,
      isApprovedByVideographer: isApprovedByVideographer,
    \);'''

replacement = '''  Future<String?> assignTask({
    required String title,
    required String description,
    required String assignedTo,
    required DateTime deadline,
    String? clientId,
    String? taskType,
    String? instructions,
    List<String> sessionClientIds = const [],
    bool isApprovedByVideographer = false,
    double? manualPaymentAmount,
  }) async {
    if (title.trim().isEmpty) return 'ERROR: Task title is required.';

    final newTask = Task(
      id: '', // Firestore generates this
      title: title,
      description: description,
      assignedTo: assignedTo,
      assignedBy: _activePersona.id,
      deadline: deadline,
      clientId: clientId,
      taskType: taskType,
      instructions: instructions,
      sessionClientIds: sessionClientIds,
      isApprovedByVideographer: isApprovedByVideographer,
      manualPaymentAmount: manualPaymentAmount,
    );'''

content = re.sub(pattern, replacement, content)

with open('lib/state/app_state.dart', 'w', encoding='utf-8') as f:
    f.write(content)
