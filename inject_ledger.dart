import 'dart:io';

void main() {
  final files = [
    'lib/screens/ceo_dashboard.dart',
    'lib/screens/cofounder_dashboard.dart',
  ];

  for (final path in files) {
    final file = File(path);
    var content = file.readAsStringSync();

    // 1. Add E-COM LEDGER to the sub-tab buttons
    String oldTabRow = r'''
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => setState(() => _clientSubTab = 'REVIEW'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _clientSubTab == 'REVIEW' ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Badge(
                    isLabelVisible: reviewClients.isNotEmpty,
                    label: Text(reviewClients.length.toString()),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Text(
                        "REVIEW",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _clientSubTab == 'REVIEW' ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
''';

    String newTabRow = r'''
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => setState(() => _clientSubTab = 'REVIEW'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _clientSubTab == 'REVIEW' ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Badge(
                    isLabelVisible: reviewClients.isNotEmpty,
                    label: Text(reviewClients.length.toString()),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Text(
                        "REVIEW",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _clientSubTab == 'REVIEW' ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => setState(() => _clientSubTab = 'LEDGER'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _clientSubTab == 'LEDGER' ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Text(
                    "E-COM LEDGER",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _clientSubTab == 'LEDGER' ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
''';
    content = content.replaceFirst(oldTabRow, newTabRow);

    // 2. Handle the rendering of LEDGER vs other clients
    String oldRenderLogic = r'''
        if (displayedClients.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Center(
                child: Text(_clientSubTab == 'ACTIVE' ? "NO ACTIVE CLIENT CONTRACTS" : (_clientSubTab == 'LEADS' ? "NO LEADS FOUND" : "NO CLIENTS PENDING APPROVAL"), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            )
          else
            ...displayedClients.map((c) {
''';

    String newRenderLogic = r'''
        if (_clientSubTab == 'LEDGER')
          _buildEcomLedgerView(state)
        else if (displayedClients.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Center(
                child: Text(_clientSubTab == 'ACTIVE' ? "NO ACTIVE CLIENT CONTRACTS" : (_clientSubTab == 'LEADS' ? "NO LEADS FOUND" : "NO CLIENTS PENDING APPROVAL"), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            )
          else
            ...displayedClients.map((c) {
''';
    content = content.replaceFirst(oldRenderLogic, newRenderLogic);

    // 3. Inject the _buildEcomLedgerView function right before _buildClientsTab
    if (!content.contains('Widget _buildEcomLedgerView')) {
      String ledgerFunc = r'''
  Widget _buildEcomLedgerView(AppState state) {
    final ecomClients = state.clients.where((c) => c.serviceType.toLowerCase().contains('commerce') && c.ecomPaymentType == 'Per SKU').toList();
    
    if (ecomClients.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: const Center(
          child: Text("NO E-COMMERCE CLIENTS FOUND", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
      );
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: ecomClients.length,
      itemBuilder: (context, i) {
        final c = ecomClients[i];
        return InkWell(
          onTap: () {
            // Open full historical ledger for this client
            _showFullClientLedger(context, c);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.amber.shade100, // Folder-like color
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade700, width: 1.5),
              boxShadow: const [BoxShadow(color: Colors.black12, offset: Offset(2, 2))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 48, color: Colors.amber.shade800),
                const SizedBox(height: 12),
                Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
                Text("${c.ecomSkuLogs.length} Total Logs", style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFullClientLedger(BuildContext context, Client c) {
    final logs = List.of(c.ecomSkuLogs)..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: SageColors.background,
          title: Text("Historical Ledger - ${c.name}", style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 800,
            height: 500,
            child: logs.isEmpty ? const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("No SKUs logged ever."),
            ) : SingleChildScrollView(
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
                columns: const [
                  DataColumn(label: Text("Date & Time", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Added By", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("SKU", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Duplicate", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Catalogue", style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("Amount", style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: logs.map((log) {
                  final amount = (log.sku * c.clientSkuRate) + (log.duplicate * c.clientDuplicateSkuRate) + (log.catalogue * c.clientCatalogueRate);
                  return DataRow(cells: [
                    DataCell(Text("${log.timestamp.day}-${log.timestamp.month}-${log.timestamp.year} ${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}")),
                    DataCell(Text(log.addedBy.isEmpty ? 'Unknown' : log.addedBy)),
                    DataCell(Text("${log.sku}")),
                    DataCell(Text("${log.duplicate}")),
                    DataCell(Text("${log.catalogue}")),
                    DataCell(Text("₹${amount.toStringAsFixed(0)}")),
                  ]);
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CLOSE", style: TextStyle(color: Colors.black54))),
          ],
        );
      }
    );
  }
''';
      content = content.replaceFirst(
        '  Widget _buildClientsTab() {',
        ledgerFunc + '\n  Widget _buildClientsTab() {',
      );
    }

    file.writeAsStringSync(content);
    print("Updated $path");
  }
}
