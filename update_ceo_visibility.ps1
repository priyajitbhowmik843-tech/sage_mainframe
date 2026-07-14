$path = "c:\Users\Priyajit Bhowmik\Downloads\n sage os\sage os\sage os\sage_mainframe\lib\screens\ceo_dashboard.dart"
$content = Get-Content -Path $path -Raw

$target = @"
        if (state.clients.any((c) => c.isTerminationRequested)) ...[
          TerminalPanel(
            title: "PENDING LEAD TERMINATIONS",
            child: Column(
              children: state.clients.where((c) => c.isTerminationRequested).map((c) => Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    ElevatedButton(
                      onPressed: () => state.approveLeadTermination(c.id),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                      child: const Text("APPROVE", style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => state.rejectLeadTermination(c.id),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                      child: const Text("REJECT", style: TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
"@

$replacement = @"
        TerminalPanel(
          title: "PENDING LEAD TERMINATIONS",
          child: state.clients.any((c) => c.isTerminationRequested) ? Column(
            children: state.clients.where((c) => c.isTerminationRequested).map((c) => Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.5),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Expanded(child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  ElevatedButton(
                    onPressed: () => state.approveLeadTermination(c.id),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                    child: const Text("APPROVE", style: TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => state.rejectLeadTermination(c.id),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                    child: const Text("REJECT", style: TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                ],
              ),
            )).toList(),
          ) : const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("No pending termination requests.", style: TextStyle(color: Colors.white70)),
          ),
        ),
        const SizedBox(height: 16),
"@

$newContent = $content.Replace($target.Replace("`r", ""), $replacement.Replace("`r", ""))
Set-Content -Path $path -Value $newContent
Write-Host "Replaced ceo dashboard successfully"
