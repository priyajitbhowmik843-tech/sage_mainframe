$path = "c:\Users\Priyajit Bhowmik\Downloads\n sage os\sage os\sage os\sage_mainframe\lib\state\app_state.dart"
$lines = Get-Content -Path $path

$startIndex = -1
$endIndex = -1

for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i].Trim() -eq "// --- Static Personas ---") {
        $startIndex = $i
    }
    if ($startIndex -ne -1 -and $lines[$i].Trim() -eq "// Find next sequence number for this prefix") {
        $endIndex = $i
        break
    }
}

if ($startIndex -ne -1 -and $endIndex -ne -1) {
    $correctBlock = @"
  // --- Static Personas ---
  static final List<Persona> personas = [
    Persona(id: 'CEO-SOH-001', name: 'Sohini', role: PersonaRole.ceo, initials: 'SD', password: 'X12345'),
    Persona(id: 'COF-RIT-001', name: 'Ritam', role: PersonaRole.cofounder, initials: 'RD', password: 'X12345'),
    Persona(id: 'COF-PRI-001', name: 'Priyajit', role: PersonaRole.cofounder, initials: 'PB', password: 'X12345'),
  ];

  Persona? authenticate(String id, String password) {
    if (password.trim().isEmpty) return null;
    
    final lowerId = id.trim().toLowerCase();
    
    // Check static personas (CEO/Cofounders)
    for (var p in personas) {
      if (p.id.toLowerCase() == lowerId && p.password.trim() == password.trim()) {
        return p;
      }
    }
    
    // Check employees
    for (var emp in _employees) {
      if (emp.id.toLowerCase() == lowerId && emp.password.trim() == password.trim()) {
        return Persona(
          id: emp.id,
          name: emp.name,
          role: PersonaRole.employee,
          initials: emp.name.isNotEmpty ? emp.name[0].toUpperCase() : 'E',
          password: emp.password,
        );
      }
    }
    
    return null;
  }

  // --- Retired IDs ---
  final Set<String> _retiredIds = {};
  Set<String> get retiredIds => _retiredIds;

  // --- Employees ---
  final List<Employee> _employees = [];

  List<Employee> get employees => List.unmodifiable(_employees);

  Map<String, String>? addEmployee({
    required String name,
    required String role,
    required String department,
    double monthlySalary = 0.0,
    double perSessionRate = 0.0,
    double perVideoRate = 0.0,
    int sessionsPerMonth = 0,
  }) {
    if (name.trim().isEmpty) {
      return {'error': 'Name cannot be empty.'};
    }
    
    final prefix = name.trim().replaceAll(' ', '').toUpperCase();
    final namePart = prefix.isEmpty ? 'EMP' : prefix.substring(0, [math]::Min(3, prefix.length));
    
"@ -replace '\[math\]::Min\(3, prefix.length\)', 'min(3, prefix.length)'

    $newLines = @()
    for ($i = 0; $i -lt $startIndex; $i++) { $newLines += $lines[$i] }
    $newLines += $correctBlock.Split("`n").Replace("`r", "")
    for ($i = $endIndex; $i -lt $lines.Length; $i++) { $newLines += $lines[$i] }

    Set-Content -Path $path -Value $newLines
    Write-Host "Fixed app_state.dart"
} else {
    Write-Host "Could not find start or end index."
}
