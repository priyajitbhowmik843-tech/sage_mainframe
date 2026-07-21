import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class EcomLedgerDialog extends StatefulWidget {
  final Client client;

  const EcomLedgerDialog({super.key, required this.client});

  @override
  State<EcomLedgerDialog> createState() => _EcomLedgerDialogState();
}

class _EcomLedgerDialogState extends State<EcomLedgerDialog> {
  String _searchQuery = '';

  // Add Log Form Controllers
  final _skuCtrl = TextEditingController(text: "0");
  final _duplicateCtrl = TextEditingController(text: "0");
  final _catalogueCtrl = TextEditingController(text: "0");

  @override
  void dispose() {
    _skuCtrl.dispose();
    _duplicateCtrl.dispose();
    _catalogueCtrl.dispose();
    super.dispose();
  }

  void _showAddLogDialog() {
    _skuCtrl.text = "0";
    _duplicateCtrl.text = "0";
    _catalogueCtrl.text = "0";

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            "Add SKU Log",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _skuCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "SKU Count"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _duplicateCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Duplicate Count"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _catalogueCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Catalogue Count"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SageColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final sku = int.tryParse(_skuCtrl.text) ?? 0;
                final dup = int.tryParse(_duplicateCtrl.text) ?? 0;
                final cat = int.tryParse(_catalogueCtrl.text) ?? 0;

                final state = context.read<AppState>();

                final newLog = EcomSkuLog(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  timestamp: DateTime.now(),
                  sku: sku,
                  duplicate: dup,
                  catalogue: cat,
                  addedBy: state.activePersona.name,
                );

                state.addEcomSkuLog(widget.client.id, newLog);
                Navigator.pop(ctx);
                setState(() {}); // refresh dialog
              },
              child: const Text("ADD LOG"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Refresh client from state to get latest logs
    final c = context.watch<AppState>().clients.firstWhere(
      (cl) => cl.id == widget.client.id,
      orElse: () => widget.client,
    );

    var logs = List.of(c.ecomSkuLogs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      logs = logs.where((l) {
        return l.addedBy.toLowerCase().contains(q) ||
            l.timestamp.toString().contains(q);
      }).toList();
    }

    return AlertDialog(
      backgroundColor: SageColors.background,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Historical Ledger - ${c.name}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: SageColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: _showAddLogDialog,
            icon: const Icon(Icons.add, size: 18),
            label: const Text("ADD LOG"),
          ),
        ],
      ),
      content: SizedBox(
        width: 900,
        height: 600,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "Search by Added By or Date...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: logs.isEmpty
                  ? const Center(child: Text("No SKUs match the criteria."))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.resolveWith(
                            (states) => Colors.grey.shade200,
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                "Date & Time",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Added By",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "SKU",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Duplicate",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Catalogue",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                "Amount (\u20B9)",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: logs.map((log) {
                            final amount =
                                (log.sku * c.clientSkuRate) +
                                (log.duplicate * c.clientDuplicateSkuRate) +
                                (log.catalogue * c.clientCatalogueRate);
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    "${log.timestamp.day}-${log.timestamp.month}-${log.timestamp.year} ${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}",
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    log.addedBy.isEmpty
                                        ? 'Unknown'
                                        : log.addedBy,
                                  ),
                                ),
                                DataCell(Text(log.sku.toString())),
                                DataCell(Text(log.duplicate.toString())),
                                DataCell(Text(log.catalogue.toString())),
                                DataCell(Text(amount.toStringAsFixed(0))),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("CLOSE"),
        ),
      ],
    );
  }
}
