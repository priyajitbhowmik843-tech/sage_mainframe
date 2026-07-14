$path = "c:\Users\Priyajit Bhowmik\Downloads\n sage os\sage os\sage os\sage_mainframe\lib\screens\marketing_executive_dashboard.dart"
$content = Get-Content -Path $path -Raw

$target = @"
          if (!isActive) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => _showConvertToActiveDialog(context, state, c),
                  style: ElevatedButton.styleFrom(backgroundColor: SageColors.primary, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                  child: const Text("CONVERT TO ACTIVE", style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
"@

$replacement = @"
          if (!isActive) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (c.isTerminationRequested)
                  const StatusBadge(label: "TERMINATION PENDING", color: Colors.orange)
                else
                  ElevatedButton(
                    onPressed: () {
                      state.requestLeadTermination(c.id);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                    child: const Text("REQUEST TERMINATION", style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ElevatedButton(
                  onPressed: () => _showConvertToActiveDialog(context, state, c),
                  style: ElevatedButton.styleFrom(backgroundColor: SageColors.primary, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                  child: const Text("CONVERT TO ACTIVE", style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
"@

$newContent = $content.Replace($target.Replace("`r", ""), $replacement.Replace("`r", ""))
Set-Content -Path $path -Value $newContent
Write-Host "Replaced ME dashboard successfully"
