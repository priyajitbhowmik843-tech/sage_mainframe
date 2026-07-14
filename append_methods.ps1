$path = "c:\Users\Priyajit Bhowmik\Downloads\n sage os\sage os\sage os\sage_mainframe\lib\state\app_state.dart"
$lines = Get-Content -Path $path
$lastBraceIndex = -1

for ($i = $lines.Length - 1; $i -ge 0; $i--) {
    if ($lines[$i].Trim() -eq "}") {
        $lastBraceIndex = $i
        break
    }
}

if ($lastBraceIndex -ne -1) {
    $methods = @"

  // --- Lead Termination Requests ---
  void requestLeadTermination(String clientId) {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx != -1) {
      final c = _clients[idx];
      c.isTerminationRequested = true;
      _db.collection('clients').doc(clientId).update({
        'isTerminationRequested': true,
      });
      _addLog('LEAD TERMINATION REQUESTED: `$${c.name}');
      _addNotification('Termination requested for lead: `$${c.name}', 'client_updated');
      notifyListeners();
    }
  }

  void approveLeadTermination(String clientId) {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx != -1) {
      final c = _clients[idx];
      _db.collection('clients').doc(clientId).delete();
      _clients.removeAt(idx);
      _addLog('LEAD TERMINATION APPROVED AND DELETED: `$${c.name}');
      _addNotification('Lead deleted: `$${c.name}', 'client_updated');
      notifyListeners();
    }
  }

  void rejectLeadTermination(String clientId) {
    final idx = _clients.indexWhere((c) => c.id == clientId);
    if (idx != -1) {
      final c = _clients[idx];
      c.isTerminationRequested = false;
      _db.collection('clients').doc(clientId).update({
        'isTerminationRequested': false,
      });
      _addLog('LEAD TERMINATION REJECTED: `$${c.name}');
      _addNotification('Termination rejected for lead: `$${c.name}', 'client_updated');
      notifyListeners();
    }
  }
"@

    $newLines = @()
    for ($i = 0; $i -lt $lastBraceIndex; $i++) { $newLines += $lines[$i] }
    $newLines += $methods.Split("`n").Replace("`r", "")
    $newLines += "}"

    Set-Content -Path $path -Value $newLines
    Write-Host "Appended methods to app_state.dart"
} else {
    Write-Host "Could not find last brace."
}
