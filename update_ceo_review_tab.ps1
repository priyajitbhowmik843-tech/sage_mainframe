$path = "c:\Users\Priyajit Bhowmik\Downloads\n sage os\sage os\sage os\sage_mainframe\lib\screens\ceo_dashboard.dart"
$content = Get-Content -Path $path -Raw

$target1 = "final reviewClients = state.clients.where((c) => !c.isApprovedByCeo).toList();"
$replacement1 = "final reviewClients = state.clients.where((c) => !c.isApprovedByCeo || c.isTerminationRequested).toList();"

$target2 = @"
                      if (_clientSubTab == 'REVIEW') ...[
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
"@

$replacement2 = @"
                      if (_clientSubTab == 'REVIEW') ...[
                        if (c.isTerminationRequested) ...[
                          TextButton(
                            onPressed: () {
                              context.read<AppState>().rejectLeadTermination(c.id);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Termination request rejected.")));
                            },
                            child: const Text("REJECT TERMINATION", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              context.read<AppState>().approveLeadTermination(c.id);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Termination request approved.")));
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: const Text("APPROVE TERMINATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
"@

$newContent = $content.Replace($target1.Replace("`r", ""), $replacement1.Replace("`r", ""))
$newContent = $newContent.Replace($target2.Replace("`r", ""), $replacement2.Replace("`r", ""))
Set-Content -Path $path -Value $newContent
Write-Host "Updated ceo_dashboard successfully"
