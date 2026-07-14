import 'dart:io';

void main() {
  final ceoFile = File('lib/screens/ceo_dashboard.dart');
  var ceoContent = ceoFile.readAsStringSync();

  // 1. Fix pendingCount in CEO
  final badPendingCount = '''    final int pendingCount = state.tasks.where((t) {
      if (t.isCompleted) return false;
      final now = DateTime.now();''';
  final goodPendingCount = '''    final int pendingCount = state.tasks.where((t) {
      if (t.isCompleted) return false;
      if ((t.taskType ?? '').toLowerCase().contains('upload') || t.title.toLowerCase().contains('upload')) return false;
      final now = DateTime.now();''';
  if (ceoContent.contains(badPendingCount)) ceoContent = ceoContent.replaceAll(badPendingCount, goodPendingCount);

  // 2. Fix top metric in CEO
  final badTopMetric = '''    final pendingTasks = state.tasks.where((t) => !t.isCompleted).length;''';
  final goodTopMetric = '''    final pendingTasks = state.tasks.where((t) => !t.isCompleted && !(t.taskType ?? '').toLowerCase().contains('upload') && !t.title.toLowerCase().contains('upload')).length;''';
  if (ceoContent.contains(badTopMetric)) ceoContent = ceoContent.replaceAll(badTopMetric, goodTopMetric);

  // 3. Robustify pendingTasks filter in CEO
  final badPendingTasks = '''      if ((t.taskType ?? '').toLowerCase().contains('upload')) return false;''';
  final goodPendingTasks = '''      if ((t.taskType ?? '').toLowerCase().contains('upload') || t.title.toLowerCase().contains('upload')) return false;''';
  // We only replace the first occurrence which is in _buildTaskPendingSubTab (or all of them)
  ceoContent = ceoContent.replaceAll(badPendingTasks, goodPendingTasks);

  ceoFile.writeAsStringSync(ceoContent);
  print("Updated CEO");

  final cfoFile = File('lib/screens/cofounder_dashboard.dart');
  var cfoContent = cfoFile.readAsStringSync();

  // 1. Fix pendingCount in CFO
  final badCfoPendingCount = '''    final int pendingCount = state.tasks.where((t) {
      if (t.isCompleted) return false;
      final isToday = t.deadline.year == now.year && t.deadline.month == now.month && t.deadline.day == now.day;''';
  final goodCfoPendingCount = '''    final int pendingCount = state.tasks.where((t) {
      if (t.isCompleted) return false;
      if ((t.taskType ?? '').toLowerCase().contains('upload') || t.title.toLowerCase().contains('upload')) return false;
      final isToday = t.deadline.year == now.year && t.deadline.month == now.month && t.deadline.day == now.day;''';
  if (cfoContent.contains(badCfoPendingCount)) cfoContent = cfoContent.replaceAll(badCfoPendingCount, goodCfoPendingCount);

  // 2. Robustify pendingTasks filter in CFO
  cfoContent = cfoContent.replaceAll(badPendingTasks, goodPendingTasks);

  cfoFile.writeAsStringSync(cfoContent);
  print("Updated CFO");
}
