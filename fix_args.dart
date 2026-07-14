
import "dart:io";

void main() {
  final ceoFile = File("lib/screens/ceo_dashboard.dart");
  var ceoText = ceoFile.readAsStringSync();
  ceoText = ceoText.replaceAll(
    "context.read<AppState>().updateClient(c.id, {\n                                          'isWebsiteHandlingActive': true,\n                                          'websiteHandlingFee': double.tryParse(feeCtrl.text) ?? 0.0,\n                                        });",
    "context.read<AppState>().updateClient(c.id, isWebsiteHandlingActive: true, websiteHandlingFee: double.tryParse(feeCtrl.text) ?? 0.0);"
  );
  ceoText = ceoText.replaceAll(
    "context.read<AppState>().updateClient(c.id, {\n                              'isWebsiteHandlingActive': false,\n                              'websiteHandlingFee': 0.0,\n                            });",
    "context.read<AppState>().updateClient(c.id, isWebsiteHandlingActive: false, websiteHandlingFee: 0.0);"
  );
  ceoFile.writeAsStringSync(ceoText);

  final cfoFile = File("lib/screens/cofounder_dashboard.dart");
  var cfoText = cfoFile.readAsStringSync();
  cfoText = cfoText.replaceAll(
    "context.read<AppState>().updateClient(c.id, {\n                                            \"isWebsiteHandlingActive\": true,\n                                            \"websiteHandlingFee\": double.tryParse(feeCtrl.text) ?? 0.0,\n                                          });",
    "context.read<AppState>().updateClient(c.id, isWebsiteHandlingActive: true, websiteHandlingFee: double.tryParse(feeCtrl.text) ?? 0.0);"
  );
  cfoText = cfoText.replaceAll(
    "context.read<AppState>().updateClient(c.id, {\n                                \"isWebsiteHandlingActive\": false,\n                                \"websiteHandlingFee\": 0.0,\n                              });",
    "context.read<AppState>().updateClient(c.id, isWebsiteHandlingActive: false, websiteHandlingFee: 0.0);"
  );
  cfoFile.writeAsStringSync(cfoText);
  print("Fixed updateClient arguments in both dashboards.");
}

