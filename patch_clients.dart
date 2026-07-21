import 'dart:io';

void patchFile(String filePath) {
  File file = File(filePath);
  String content = file.readAsStringSync();

  // 1. Add Website Handling to Contract Tenure / Monthly Fee
  if (!content.contains('isWebsiteHandlingActive')) {
    print("Patching Website Handling row in $filePath...");
    String oldPattern = """                    c.ecomPaymentType == 'Per SKU'
                        ? _buildClientDetailRow(
                            "Base Monthly Fee",
                            "\\u20B9\${c.getPayableForMonth(DateTime.now().month, DateTime.now().year).toStringAsFixed(0)} (Actual varies by SKU logs)",
                          )
                        : _buildClientDetailRow(
                            "Monthly Fee",
                            "\\u20B9\${c.monthlyPayable.toStringAsFixed(0)}",
                          ),""";
    String newPattern = """                    if (c.isWebsiteHandlingActive)
                      _buildClientDetailRow(
                        "Website Handling",
                        "\\u20B9\${c.websiteHandlingFee.toStringAsFixed(0)}",
                      ),
                    c.ecomPaymentType == 'Per SKU'
                        ? _buildClientDetailRow(
                            "Base Monthly Fee",
                            "\\u20B9\${c.getPayableForMonth(DateTime.now().month, DateTime.now().year).toStringAsFixed(0)} (Actual varies by SKU logs)",
                          )
                        : _buildClientDetailRow(
                            "Monthly Fee",
                            "\\u20B9\${(c.monthlyPayable + (c.isWebsiteHandlingActive ? c.websiteHandlingFee : 0)).toStringAsFixed(0)}",
                          ),""";
    if (content.contains(oldPattern)) {
      content = content.replaceAll(oldPattern, newPattern);
    } else {
      // Try alternative pattern for CFO dashboard
      String oldCfoPattern = """                    c.ecomPaymentType == 'Per SKU' ? _buildClientDetailRow("Base Monthly Fee", "\\u20B9\${c.getPayableForMonth(DateTime.now().month, DateTime.now().year).toStringAsFixed(0)} (Actual varies by SKU logs)") : _buildClientDetailRow("Monthly Fee", "\\u20B9\${c.monthlyPayable.toStringAsFixed(0)}"),""";
      String newCfoPattern = """                    if (c.isWebsiteHandlingActive) _buildClientDetailRow("Website Handling", "\\u20B9\${c.websiteHandlingFee.toStringAsFixed(0)}"),
                    c.ecomPaymentType == 'Per SKU' ? _buildClientDetailRow("Base Monthly Fee", "\\u20B9\${c.getPayableForMonth(DateTime.now().month, DateTime.now().year).toStringAsFixed(0)} (Actual varies by SKU logs)") : _buildClientDetailRow("Monthly Fee", "\\u20B9\${(c.monthlyPayable + (c.isWebsiteHandlingActive ? c.websiteHandlingFee : 0)).toStringAsFixed(0)}"),""";
      content = content.replaceAll(oldCfoPattern, newCfoPattern);
    }
  }

  // 2. Add Website Handling Toggle & Add-Ons list
  if (!content.contains('"Add-Ons"')) {
    print("Patching Add-Ons and Website Handling Toggle in $filePath...");
    String hook = """                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _showSkuLogDialog(context, c),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D0E0E),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Log Daily SKUs"),
                          ),
                        ],
                      ),
                    ],""";
    String inserted = """                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => _showSkuLogDialog(context, c),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D0E0E),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Log Daily SKUs"),
                          ),
                        ],
                      ),
                    ],
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
                        onChanged: (val) async {
                          if (val) {
                            final ok = await showConfirmDialog(context, "Enable Website Handling", "Are you sure you want to enable the Website Handling Service for \${c.name}?");
                            if (!ok || !context.mounted) return;
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
                                        context.read<AppState>().updateClient(c.id, isWebsiteHandlingActive: true, websiteHandlingFee: double.tryParse(feeCtrl.text) ?? 0.0);
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text("SAVE"),
                                    ),
                                  ],
                                );
                              }
                            );
                          } else {
                            final ok = await showConfirmDialog(context, "Disable Website Handling", "Are you sure you want to disable the Website Handling Service for \${c.name}?");
                            if (!ok || !context.mounted) return;
                            context.read<AppState>().updateClient(c.id, isWebsiteHandlingActive: false, websiteHandlingFee: 0.0);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Add-Ons",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (c.addOns.isNotEmpty)
                      ...c.addOns.map(
                        (addOn) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "\${addOn.type} - \\u20B9\${addOn.amount.toStringAsFixed(0)}" + (addOn.description != null && addOn.description!.isNotEmpty ? " (\${addOn.description})" : ""),
                                style: const TextStyle(fontSize: 12, color: Colors.black87),
                              ),
                            ),
                            if (addOn.isPaid)
                              const Icon(Icons.check_circle, color: Colors.green, size: 16)
                            else if (addOn.isBilled)
                              const Text("BILLED", style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold))
                            else
                              const Text("UNBILLED", style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ).toList()
                    else
                      const Text("No add-ons.", style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              String type = 'Event Shoot';
                              final descCtrl = TextEditingController();
                              final amtCtrl = TextEditingController();
                              return StatefulBuilder(
                                builder: (ctx, setState) {
                                  return AlertDialog(
                                    title: const Text("Add New Add-On"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        DropdownButtonFormField<String>(
                                          value: type,
                                          decoration: const InputDecoration(labelText: "Type"),
                                          items: ['Event Shoot', 'Ad Campaign Budget', 'Extra Deliverable', 'Other']
                                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                              .toList(),
                                          onChanged: (v) => setState(() => type = v!),
                                        ),
                                        const SizedBox(height: 10),
                                        TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description (Optional)")),
                                        const SizedBox(height: 10),
                                        TextField(controller: amtCtrl, decoration: const InputDecoration(labelText: "Amount (\\u20B9)"), keyboardType: TextInputType.number),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
                                      TextButton(
                                        onPressed: () {
                                          final amt = double.tryParse(amtCtrl.text) ?? 0.0;
                                          if (amt > 0) {
                                            context.read<AppState>().addClientAddOn(
                                              c.id,
                                              ClientAddOn(
                                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                                type: type,
                                                description: descCtrl.text,
                                                amount: amt,
                                              ),
                                            );
                                          }
                                          Navigator.pop(ctx);
                                        },
                                        child: const Text("ADD"),
                                      ),
                                    ],
                                  );
                                }
                              );
                            }
                          );
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text("NEW ADD-ON", style: TextStyle(fontSize: 11)),
                      ),
                    ),""";
    content = content.replaceAll(hook, inserted);
  }

  // 3. Add Generate Invoice Button
  if (!content.contains('"GENERATE INVOICE"')) {
    print("Patching Generate Invoice button in $filePath...");
    String buttonHook = """                          TextButton(
                            onPressed: () => _showEditClientDialog(context, c),
                            child: const Text("EDIT", style: TextStyle(color: SageColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),""";
    String insertedButton = """                          TextButton(
                            onPressed: () {
                              _showInvoiceMonthDialog(context, c);
                            },
                            child: const Text(
                              "GENERATE INVOICE",
                              style: TextStyle(
                                color: SageColors.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _showEditClientDialog(context, c),
                            child: const Text("EDIT", style: TextStyle(color: SageColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),""";
    
    if (content.contains(buttonHook)) {
      content = content.replaceAll(buttonHook, insertedButton);
    } else {
      String fallbackButtonHook = """                          TextButton(
                            onPressed: () => _showEditClientDialog(context, c),
                            child: const Text(
                              "EDIT",
                              style: TextStyle(
                                color: SageColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),""";
      String fallbackInsertedButton = """                          TextButton(
                            onPressed: () {
                              _showInvoiceMonthDialog(context, c);
                            },
                            child: const Text(
                              "GENERATE INVOICE",
                              style: TextStyle(
                                color: SageColors.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _showEditClientDialog(context, c),
                            child: const Text(
                              "EDIT",
                              style: TextStyle(
                                color: SageColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),""";
      content = content.replaceAll(fallbackButtonHook, fallbackInsertedButton);
    }
  }

  // 4. Inject _showInvoiceMonthDialog function
  if (!content.contains('void _showInvoiceMonthDialog')) {
    print("Patching _showInvoiceMonthDialog function in $filePath...");
    String funcHook = """  Widget _buildTaskCalendarSubTab() {""";
    
    var res = Process.runSync('git', ['show', 'e8d0554^:lib/screens/ceo_dashboard.dart']);
    String tempCeoContent = res.stdout.toString();
    
    int startIdx = tempCeoContent.indexOf("  void _showInvoiceMonthDialog");
    if (startIdx != -1) {
      int endIdx = tempCeoContent.indexOf("  void _showEditClientDialog", startIdx);
      if (endIdx != -1) {
        String invoiceFunc = tempCeoContent.substring(startIdx, endIdx);
        content = content.replaceAll(funcHook, invoiceFunc + "\\n" + funcHook);
      }
    } else {
      print("Could not find _showInvoiceMonthDialog in old git revision!");
    }
  }

  file.writeAsStringSync(content);
}

void main() {
  patchFile("lib/screens/ceo_dashboard.dart");
  patchFile("lib/screens/cofounder_dashboard.dart");
}
