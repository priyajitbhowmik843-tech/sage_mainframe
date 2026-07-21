import 'dart:io';

void main() {
  // 1. Fix models.dart to include isPaymentAcknowledgedByVideographer
  var modelsFile = File('lib/models/models.dart');
  var modelsContent = modelsFile.readAsStringSync();

  if (!modelsContent.contains('isPaymentAcknowledgedByVideographer')) {
    modelsContent = modelsContent.replaceFirst(
      'bool isPaidToVideographer = false;',
      'bool isPaidToVideographer = false;\n    bool isPaymentAcknowledgedByVideographer = false;',
    );

    modelsContent = modelsContent.replaceFirst(
      'this.isPaidToVideographer = false,',
      'this.isPaidToVideographer = false,\n      this.isPaymentAcknowledgedByVideographer = false,',
    );

    modelsContent = modelsContent.replaceFirst(
      "isPaidToVideographer: data['isPaidToVideographer'] ?? false,",
      "isPaidToVideographer: data['isPaidToVideographer'] ?? false,\n        isPaymentAcknowledgedByVideographer: data['isPaymentAcknowledgedByVideographer'] ?? false,",
    );

    modelsContent = modelsContent.replaceFirst(
      "'isPaidToVideographer': isPaidToVideographer,",
      "'isPaidToVideographer': isPaidToVideographer,\n        'isPaymentAcknowledgedByVideographer': isPaymentAcknowledgedByVideographer,",
    );

    modelsFile.writeAsStringSync(modelsContent);
    print('Updated models.dart');
  }

  // 2. Fix app_state.dart to add acknowledgeVideographerPayment
  var stateFile = File('lib/state/app_state.dart');
  var stateContent = stateFile.readAsStringSync();

  if (!stateContent.contains('acknowledgeVideographerPayment')) {
    int approveIdx = stateContent.indexOf(
      'void approveVideographerSession(String taskId)',
    );
    if (approveIdx != -1) {
      String newMethod = '''
  void acknowledgeVideographerPayment(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx].isPaymentAcknowledgedByVideographer = true;
      _db.collection('tasks').doc(taskId).update({'isPaymentAcknowledgedByVideographer': true});
      _addLog('PAYMENT ACKNOWLEDGED: "\${_tasks[idx].title}" by Videographer \${_activePersona.name}');
      notifyListeners();
    }
  }

''';
      stateContent =
          stateContent.substring(0, approveIdx) +
          newMethod +
          stateContent.substring(approveIdx);
      stateFile.writeAsStringSync(stateContent);
      print('Updated app_state.dart');
    }
  }

  // 3. Fix videographer_dashboard.dart finance logic
  var videoFile = File('lib/screens/videographer_dashboard.dart');
  var videoContent = videoFile.readAsStringSync();

  if (videoContent.contains('collectedAmount += c.sessionRate;')) {
    videoContent = videoContent.replaceAll(
      'for (final t in completedSessions.where((x) => x.isApprovedByVideographer)) {',
      'for (final t in completedSessions.where((x) => x.isPaymentAcknowledgedByVideographer)) {',
    );

    videoContent = videoContent.replaceAll(
      'for (final t in completedSessions.where((x) => !x.isApprovedByVideographer)) {',
      'for (final t in completedSessions.where((x) => !x.isPaymentAcknowledgedByVideographer)) {',
    );

    videoContent = videoContent.replaceAll(
      'final sessionsPendingApproval = completedSessions.where((t) => t.isPaidToVideographer && !t.isApprovedByVideographer).toList();',
      'final sessionsPendingApproval = completedSessions.where((t) => t.isPaidToVideographer && !t.isPaymentAcknowledgedByVideographer).toList();',
    );

    videoContent = videoContent.replaceAll(
      'context.read<AppState>().approveVideographerSession(t.id);',
      'context.read<AppState>().acknowledgeVideographerPayment(t.id);',
    );

    videoFile.writeAsStringSync(videoContent);
    print('Updated videographer_dashboard.dart finance logic');
  }

  // 4. Fix ceo_dashboard.dart filtering logic for booking sessions
  var ceoFile = File('lib/screens/ceo_dashboard.dart');
  var ceoContent = ceoFile.readAsStringSync();

  ceoContent = ceoContent.replaceAll(
    "final videographerClients = state.clients.where((c) => c.assignedVideographerId == _sessionVideographerId && c.status.toLowerCase() == 'active').toList();",
    "final videographerClients = state.clients.where((c) => c.assignedVideographerId == _sessionVideographerId && c.status.toLowerCase() != 'lead').toList();",
  );

  ceoFile.writeAsStringSync(ceoContent);
  print('Updated ceo_dashboard.dart');
}
