import "dart:io";

void main() {
  final ceoFile = File("lib/screens/ceo_dashboard.dart");
  var ceoText = ceoFile.readAsStringSync();

  final cfoFile = File("lib/screens/cofounder_dashboard.dart");
  var cfoText = cfoFile.readAsStringSync();

  // Extract _showAddOnPaymentDialog from ceo_dashboard
  int startIdx = ceoText.indexOf("  void _showAddOnPaymentDialog(");
  int endIdx = ceoText.indexOf("  void _showFinanceAddModal", startIdx);
  if (endIdx == -1) endIdx = ceoText.indexOf("  void ", startIdx + 10);

  String dialogCode = ceoText.substring(startIdx, endIdx);

  // Inject into cofounder_dashboard
  if (!cfoText.contains("void _showAddOnPaymentDialog(")) {
    int insertIdx = cfoText.indexOf("  void _showFinanceAddModal");
    if (insertIdx == -1)
      insertIdx = cfoText.indexOf(
        "  void ",
        cfoText.indexOf("class _CofounderDashboardState"),
      );
    cfoText =
        cfoText.substring(0, insertIdx) +
        dialogCode +
        "\n" +
        cfoText.substring(insertIdx);
  }

  // --- CFO Dashboard Add-On UI Replacement ---
  String oldCfoAddOn = """                      const SizedBox(height: 12),
                      const Text("Add-Ons", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                      const SizedBox(height: 8),
                      if (c.addOns.isNotEmpty)
                        ...c.addOns.map((addOn) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text("\${addOn.type} (Month \${addOn.month}/\${addOn.year}) \${addOn.description != null && addOn.description!.isNotEmpty ? '- \${addOn.description}' : ''}", style: const TextStyle(fontSize: 12))),
                            Row(
                              children: [
                                Text("(+\u20B9\${addOn.amount.toStringAsFixed(0)})", style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                                IconButton(icon: const Icon(Icons.delete, size: 16, color: Colors.red), onPressed: () => context.read<AppState>().deleteClientAddOn(c.id, addOn.id)),
                              ],
                            ),
                          ],
                        )),""";

  String newAddOnUI = """
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: SageColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SwitchListTile(
                          title: const Text("Website Handling Service", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                          value: c.isWebsiteHandlingActive,
                          activeColor: SageColors.primary,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) {
                            if (val) {
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  final feeCtrl = TextEditingController(text: c.websiteHandlingFee.toString());
                                  return AlertDialog(
                                    title: const Text("Website Handling Fee"),
                                    content: TextField(controller: feeCtrl, keyboardType: TextInputType.number),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
                                      TextButton(
                                        onPressed: () {
                                          context.read<AppState>().updateClient(c.id, {
                                            'isWebsiteHandlingActive': true,
                                            'websiteHandlingFee': double.tryParse(feeCtrl.text) ?? 0.0,
                                          });
                                          Navigator.pop(ctx);
                                        },
                                        child: const Text("SAVE"),
                                      ),
                                    ],
                                  );
                                }
                              );
                            } else {
                              context.read<AppState>().updateClient(c.id, {
                                'isWebsiteHandlingActive': false,
                                'websiteHandlingFee': 0.0,
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text("Add-Ons", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                      const SizedBox(height: 8),
                      if (c.addOns.isNotEmpty)
                        ...c.addOns.map((addOn) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text("\${addOn.type} \${addOn.description != null && addOn.description!.isNotEmpty ? '- \${addOn.description}' : ''}", style: const TextStyle(fontSize: 12))),
                            Row(
                              children: [
                                Text("(+\u20B9\${addOn.amount.toStringAsFixed(0)})", style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                                if (!addOn.isPaid)
                                  TextButton(
                                    onPressed: () => _showAddOnPaymentDialog(context, c, addOn),
                                    child: const Text("Pay", style: TextStyle(color: SageColors.primary, fontSize: 12)),
                                  ),
                                if (addOn.isPaid)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text("PAID", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                IconButton(icon: const Icon(Icons.delete, size: 16, color: Colors.red), onPressed: () => context.read<AppState>().deleteClientAddOn(c.id, addOn.id)),
                              ],
                            ),
                          ],
                        )),""";

  if (cfoText.contains(oldCfoAddOn)) {
    cfoText = cfoText.replaceAll(oldCfoAddOn, newAddOnUI);
    print("Replaced Add-On UI in cofounder_dashboard");
  } else {
    print("Could not find old CFO Add-On UI block");
  }

  cfoFile.writeAsStringSync(cfoText);
  print("Updated cofounder_dashboard.dart");
}
