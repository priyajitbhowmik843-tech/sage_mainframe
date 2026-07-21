import 'dart:io';

void main() {
  final file = File('lib/state/app_state.dart');
  var content = file.readAsStringSync();

  final assignTaskFind = '''
  Future<String?> assignTask({
    required String title,
    required String description,
    required String assignedTo,
    required DateTime deadline,
    String? clientId,
    String? taskType,
    String? instructions,
    List<String> sessionClientIds = const [],
    bool isApprovedByVideographer = false,
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
    );''';

  final assignTaskReplace = '''
  Future<String?> assignTask({
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
    );''';

  if (content.contains(
    'bool isApprovedByVideographer = false,\n  }) async {',
  )) {
    content = content.replaceFirst(assignTaskFind, assignTaskReplace);
  } else {
    print("Could not find assignTask exact match.");
  }

  file.writeAsStringSync(content);
}
