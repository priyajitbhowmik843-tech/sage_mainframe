import 'dart:io';

void patchFile(String filePath) {
  File file = File(filePath);
  String content = file.readAsStringSync();

  // 1. Rename SAVE PAYMENT to PAY
  content = content.replaceAll('"SAVE PAYMENT"', '"PAY"');

  // 2. Add Month Discount Field in _showInvoiceMonthDialog
  String dropdownHook = '''DropdownButtonFormField<int>(
                      value: selectedMonth,
                      decoration: const InputDecoration(
                        labelText: "Select Month",
                        fillColor: SageColors.background,
                        border: OutlineInputBorder(),
                      ),
                      items: pendingMonths.map((m) {
                        return DropdownMenuItem(
                          value: m,
                          child: Text(getMonthName(m)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedMonth = val);
                      },
                    ),''';
  
  if (!content.contains("controller: _monthDiscountCtrl,")) {
    // We need to inject the controller definition too.
    String initHook = '''    Map<String, TextEditingController> partialPaymentControllers = {};
''';
    String injectedInit = initHook + '''    TextEditingController _monthDiscountCtrl = TextEditingController(text: "0");
    Map<String, TextEditingController> addonDiscountControllers = {};
    for (var a in unbilledAddOns) {
      addonDiscountControllers[a.id] = TextEditingController(text: "0");
    }
''';
    content = content.replaceFirst(initHook, injectedInit);
    
    String injectedMonthDiscount = dropdownHook + '''
                    const SizedBox(height: 12),
                    TextField(
                      controller: _monthDiscountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Month Discount (\\u20B9)",
                        fillColor: SageColors.background,
                        border: OutlineInputBorder(),
                      ),
                    ),''';
    content = content.replaceFirst(dropdownHook, injectedMonthDiscount);
  }

  // 3. Add Addon Discount Field
  String partialPaymentHook = '''                                      Expanded(
                                        child: TextField(
                                          controller: partialPaymentControllers[addOn.id],
                                          keyboardType: TextInputType.number,
                                          style: const TextStyle(color: SageColors.onSurface, fontSize: 12),
                                          decoration: const InputDecoration(
                                            hintText: "Amount (\\u20B9)",
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                          ),
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                              ),''';
  
  if (!content.contains("controller: addonDiscountControllers[addOn.id]")) {
    String injectedAddonDiscount = partialPaymentHook + '''
                            if (isSelected)
                              Padding(
                                padding: const EdgeInsets.only(left: 32.0, bottom: 8.0, right: 16.0),
                                child: TextField(
                                  controller: addonDiscountControllers[addOn.id],
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: SageColors.onSurface, fontSize: 12),
                                  decoration: const InputDecoration(
                                    labelText: "Discount (\\u20B9)",
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  ),
                                ),
                              ),''';
    content = content.replaceAll(partialPaymentHook, injectedAddonDiscount);
  }

  // 4. Update InvoiceService.generateAndShareInvoice call
  String invoiceCallHook = '''                      await InvoiceService.generateAndShareInvoice(
                        c,
                        invoiceDate,
                        selectedAddOns: selectedAddOnsForInvoice,
                      );''';
  
  String injectedInvoiceCall = '''                      double md = double.tryParse(_monthDiscountCtrl.text) ?? 0.0;
                      // Update the discount on the addons before passing them
                      for (var a in selectedAddOnsForInvoice) {
                        a.discount = double.tryParse(addonDiscountControllers[a.id]?.text ?? '0') ?? 0.0;
                      }
                      
                      await InvoiceService.generateAndShareInvoice(
                        c,
                        invoiceDate,
                        selectedAddOns: selectedAddOnsForInvoice,
                        monthDiscount: md,
                      );''';

  if (!content.contains("monthDiscount: md")) {
    content = content.replaceFirst(invoiceCallHook, injectedInvoiceCall);
  }

  // 5. Add Pay Addon generic method.
  if (!content.contains("void _showPayAddOnDialog")) {
    String payAddonMethod = '''  void _showPayAddOnDialog(BuildContext context, Client c) {
    List<ClientAddOn> unpaidAddOns = c.addOns.where((a) => !a.isPaid).toList();
    if (unpaidAddOns.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("No Unpaid Add-Ons"),
          content: const Text("This client has no unpaid add-ons."),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
        ),
      );
      return;
    }

    String selectedAddOnId = unpaidAddOns.first.id;
    String paymentMethod = 'UPI';
    DateTime paymentDate = DateTime.now();
    TextEditingController amountCtrl = TextEditingController();
    TextEditingController discountCtrl = TextEditingController(text: "0");

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            final addOn = unpaidAddOns.firstWhere((a) => a.id == selectedAddOnId);
            if (amountCtrl.text.isEmpty) {
              amountCtrl.text = addOn.amount.toStringAsFixed(0);
            }
            return AlertDialog(
              title: Text("Pay Add-On for \"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedAddOnId,
                      decoration: const InputDecoration(labelText: "Select Add-On"),
                      items: unpaidAddOns.map((a) => DropdownMenuItem(value: a.id, child: Text("\ (\\u20B9\)"))).toList(),
                      onChanged: (v) {
                        setState(() {
                          selectedAddOnId = v!;
                          amountCtrl.text = unpaidAddOns.firstWhere((a) => a.id == selectedAddOnId).amount.toStringAsFixed(0);
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Amount Paid (\\u20B9)"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: discountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Discount (\\u20B9)"),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: paymentMethod,
                      decoration: const InputDecoration(labelText: "Payment Method"),
                      items: ['UPI', 'Bank Transfer', 'Cash'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (v) => setState(() => paymentMethod = v!),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: paymentDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (d != null) setState(() => paymentDate = d);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: "Date", border: OutlineInputBorder()),
                        child: Text(paymentDate.toString().substring(0, 10)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
                ElevatedButton(
                  onPressed: () {
                    double amtPaid = double.tryParse(amountCtrl.text) ?? addOn.amount;
                    double discount = double.tryParse(discountCtrl.text) ?? 0.0;
                    context.read<AppState>().payClientAddOn(
                      c.id,
                      selectedAddOnId,
                      paymentMethod,
                      paymentDate,
                      amountPaid: amtPaid,
                      discountAmount: discount,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text("PAY"),
                ),
              ],
            );
          },
        );
      },
    );
  }
''';
    
    // Inject _showPayAddOnDialog just before _showInvoiceMonthDialog
    String funcHook = "  void _showInvoiceMonthDialog";
    content = content.replaceFirst(funcHook, payAddonMethod + "\\n" + funcHook);
  }

  // 6. Inject PAY ADDON button in Clients UI
  String buttonHook = '''                      TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              String type = 'Event Shoot';''';
  String injectedButton = '''                      TextButton.icon(
                        onPressed: () => _showPayAddOnDialog(context, c),
                        icon: const Icon(Icons.payment, size: 16),
                        label: const Text("PAY ADD-ON", style: TextStyle(fontSize: 11)),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              String type = 'Event Shoot';''';
  if (!content.contains('"PAY ADD-ON"')) {
    content = content.replaceFirst(buttonHook, injectedButton);
  }

  // Convert all Windows CRLF to standard LF to avoid formatting issues in Dart
  content = content.replaceAll("\\r\\n", "\\n");

  file.writeAsStringSync(content);
}

void main() {
  patchFile("lib/screens/ceo_dashboard.dart");
  patchFile("lib/screens/cofounder_dashboard.dart");
}
