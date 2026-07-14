import 'dart:io';

void main() {
  final file = File('lib/state/app_state.dart');
  var content = file.readAsStringSync();

  final oldLine = r"final unpaidSessions = _tasks.where((t) => t.assignedTo == videographerId && (isVideoEditor ? (t.taskType == 'Reel' || t.taskType == 'Video') : t.taskType == 'Session') && t.isCompleted && !t.isPaidToVideographer).toList();";
  final newLine = r"final unpaidSessions = _tasks.where((t) => t.assignedTo == videographerId && (isVideoEditor ? true : t.taskType == 'Session') && t.isCompleted && !t.isPaidToVideographer).toList();";
  
  if (content.contains(oldLine)) {
    content = content.replaceFirst(oldLine, newLine);
    file.writeAsStringSync(content);
    print('Fixed taskType filtering for Video Editors in app_state.dart');
  } else {
    print('Could not find the line to replace');
  }
}
