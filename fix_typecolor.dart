import 'dart:io';

void main() {
  // CEO Dashboard
  var ceoFile = File('lib/screens/ceo_dashboard.dart');
  var ceoContent = ceoFile.readAsStringSync();
  
  ceoContent = ceoContent.replaceAll(
    '      return Column(\n        children: pendingTasks.map((t) {\n          final submissionDateStr = t.submittedAt != null ',
    '      return Column(\n        children: pendingTasks.map((t) {\n          Color typeColor = Colors.black;\n          final submissionDateStr = t.submittedAt != null '
  );
  
  ceoContent = ceoContent.replaceAll(
    '      return Column(\n        children: completedTasks.take(50).map((t) { // Limit to 50 for performance\n        return Container(',
    '      return Column(\n        children: completedTasks.take(50).map((t) { // Limit to 50 for performance\n        Color typeColor = Colors.black;\n        return Container('
  );
  
  ceoFile.writeAsStringSync(ceoContent);

  // CFO Dashboard
  var cfoFile = File('lib/screens/cofounder_dashboard.dart');
  var cfoContent = cfoFile.readAsStringSync();
  
  cfoContent = cfoContent.replaceAll(
    '      return Column(\n        children: pendingTasks.map((t) {\n          return Container(',
    '      return Column(\n        children: pendingTasks.map((t) {\n          Color typeColor = Colors.black;\n          return Container('
  );
  
  cfoContent = cfoContent.replaceAll(
    '      return Column(\n        children: completedTasks.take(50).map((t) { // Limit to 50 for performance\n          return Container(',
    '      return Column(\n        children: completedTasks.take(50).map((t) { // Limit to 50 for performance\n          Color typeColor = Colors.black;\n          return Container('
  );
  
  cfoFile.writeAsStringSync(cfoContent);
  print('Fixed files!');
}
