import 'dart:io';

void main() {
  final ceoFile = File('lib/screens/ceo_dashboard.dart');
  var ceoContent = ceoFile.readAsStringSync();

  // Revert MyTasks filter in CEO
  final badMyTasks =
      r"final myTasks = state.tasks.where((t) => t.assignedTo == state.activePersona.id && !t.isCompleted && !(t.taskType ?? '').toLowerCase().contains('upload')).toList();";
  final correctMyTasks =
      r"final myTasks = state.tasks.where((t) => t.assignedTo == state.activePersona.id && !t.isCompleted).toList();";

  if (ceoContent.contains(badMyTasks)) {
    ceoContent = ceoContent.replaceAll(badMyTasks, correctMyTasks);
    ceoFile.writeAsStringSync(ceoContent);
    print("Fixed CEO myTasks");
  } else {
    print("CEO myTasks not found");
  }

  final cfoFile = File('lib/screens/cofounder_dashboard.dart');
  var cfoContent = cfoFile.readAsStringSync();

  // Revert MyTasks filter in CFO
  if (cfoContent.contains(badMyTasks)) {
    cfoContent = cfoContent.replaceAll(badMyTasks, correctMyTasks);
    cfoFile.writeAsStringSync(cfoContent);
    print("Fixed CFO myTasks");
  } else {
    print("CFO myTasks not found");
  }
}
