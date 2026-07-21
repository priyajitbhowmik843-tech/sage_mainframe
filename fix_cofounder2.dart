import "dart:io";

void main() {
  final ceoFile = File("lib/screens/ceo_dashboard.dart");
  final ceoText = ceoFile.readAsStringSync();

  int startIdx = ceoText.indexOf("  void _showAddOnPaymentDialog(");
  int endIdx = ceoText.indexOf("  void _showInvoiceMonthDialog", startIdx);
  if (endIdx == -1) endIdx = ceoText.indexOf("  void ", startIdx + 10);

  String dialogCode = ceoText.substring(startIdx, endIdx);

  final cfoFile = File("lib/screens/cofounder_dashboard.dart");
  var cfoText = cfoFile.readAsStringSync();

  if (!cfoText.contains("void _showAddOnPaymentDialog(")) {
    int lastBraceIdx = cfoText.lastIndexOf("}");
    cfoText = cfoText.substring(0, lastBraceIdx) + "\n" + dialogCode + "\n}\n";
  }

  // Next, replace the Add-Ons UI block in CFO Dashboard
  int addOnsTitleIdx = cfoText.indexOf(
    "const Text(\"Add-Ons\", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),",
  );
  if (addOnsTitleIdx != -1) {
    // We want to find the start of `const SizedBox(height: 12);` right before it
    int startBlock = cfoText.lastIndexOf(
      "const SizedBox(height: 12);",
      addOnsTitleIdx,
    );
    if (startBlock == -1)
      startBlock = cfoText.lastIndexOf(
        "const SizedBox(height: 12),",
        addOnsTitleIdx,
      );

    // Find the end of the Add-Ons block, which is right before `Align(` for "Add New Add-On"
    int endBlock = cfoText.indexOf("Align(", addOnsTitleIdx);

    if (startBlock != -1 && endBlock != -1) {
      String newUI = """
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
                                            "isWebsiteHandlingActive": true,
                                            "websiteHandlingFee": double.tryParse(feeCtrl.text) ?? 0.0,
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
                                "isWebsiteHandlingActive": false,
                                "websiteHandlingFee": 0.0,
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
                        )),
                      """;
      cfoText =
          cfoText.substring(0, startBlock) +
          newUI +
          cfoText.substring(endBlock);
      print("UI Replaced in CFO Dashboard.");
    } else {
      print("Could not find startBlock or endBlock.");
    }
  } else {
    print("Could not find addOnsTitleIdx.");
  }

  cfoFile.writeAsStringSync(cfoText);
  print("CFO Dashboard fixed.");
}
