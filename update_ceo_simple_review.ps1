$path = "c:\Users\Priyajit Bhowmik\Downloads\n sage os\sage os\sage os\sage_mainframe\lib\screens\ceo_dashboard.dart"
$content = Get-Content -Path $path -Raw

$target = @"
        else
          ...displayedClients.map((c) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
"@

$replacement = @"
        else
          ...displayedClients.map((c) {
            if (_clientSubTab == 'REVIEW') {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 1.5),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                    Text("Contact: ${c.contact.name} (${c.contact.phone})", style: const TextStyle(fontSize: 11, color: Colors.black54)),
                    if (c.isTerminationRequested)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text("â€¢ Requested Termination", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text("â€¢ Requested Conversion to Active Client", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (c.isTerminationRequested) ...[
                          TextButton(
                            onPressed: () {
                              context.read<AppState>().rejectLeadTermination(c.id);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Termination request rejected.")));
                            },
                            child: const Text("REJECT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              context.read<AppState>().approveLeadTermination(c.id);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Termination request approved.")));
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: const Text("APPROVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ] else ...[
                          TextButton(
                            onPressed: () {
                              context.read<AppState>().rejectClientConversion(c.id);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Client conversion rejected.")));
                            },
                            child: const Text("REJECT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              context.read<AppState>().approveClientConversion(c.id);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Client conversion approved.")));
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: const Text("APPROVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
"@

$newContent = $content.Replace($target.Replace("`r", ""), $replacement.Replace("`r", ""))
Set-Content -Path $path -Value $newContent
Write-Host "Updated ceo_dashboard map successfully"
