import 'dart:io';

void fixMissingUpdateClientArgs(String filename) {
  var file = File(filename);
  if (!file.existsSync()) return;
  var content = file.readAsStringSync();

  var brokenCall =
      '''                        weeklyStories: int.tryParse(storiesCtrl.text),
                        campaigns: int.tryParse(campaignsCtrl.text),
                        campaignReach: campaignReachCtrl.text,
                        postRequirements: guidelinesCtrl.text,
                      );''';

  var fixedCall =
      '''                        weeklyStories: int.tryParse(storiesCtrl.text),
                        campaigns: int.tryParse(campaignsCtrl.text),
                        campaignReach: campaignReachCtrl.text,
                        assignedVideographerId: assignedVideographerId,
                        sessionRate: double.tryParse(sessionRateCtrl.text),
                        postRequirements: guidelinesCtrl.text,
                      );''';

  content = content.replaceAll(brokenCall, fixedCall);
  file.writeAsStringSync(content);
}

void main() {
  fixMissingUpdateClientArgs('lib/screens/cofounder_dashboard.dart');
  fixMissingUpdateClientArgs('lib/screens/cofounder_dashboard_recovered.dart');
  print('Fixed updateClient args!');
}
