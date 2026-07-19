const fs = require('fs');

function processFile(filePath) {
    let content = fs.readFileSync(filePath, 'utf8');
    
    // 1. Replace TerminalPanel wrapping pending payments
    const oldPanel = `        TerminalPanel(
          title: "PENDING PAYMENTS",
          child: _buildPendingPaymentsList(state),
        ),`;
        
    const newPanel = `        Container(
          decoration: BoxDecoration(
            color: SageColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: const Text(
                  "PENDING PAYMENTS",
                  style: TextStyle(
                    color: SageColors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: _buildPendingPaymentsList(state),
                  ),
                ],
              ),
            ),
          ),
        ),`;
        
    if (content.includes(oldPanel)) {
        content = content.replace(oldPanel, newPanel);
    }
    
    // 2. Replace _buildPendingPaymentsList
    const startStr = "  Widget _buildPendingPaymentsList(AppState state) {";
    let endStr = "// --- --- --- --- TAB 1: CLIENTS";
    
    let startIdx = content.indexOf(startStr);
    let endIdx = content.indexOf(endStr);
    
    if (startIdx !== -1 && endIdx !== -1) {
        // adjust endIdx to go back to previous new line spaces
        while(content[endIdx-1] === ' ') endIdx--;
        
        const newMethod = `  Widget _buildPendingPaymentsList(AppState state) {
    final pendingClients = state.clients
        .where(
          (c) =>
              (c.status == 'Active' || c.status == 'Retained') &&
              c.dynamicPaymentsDue > 0,
        )
        .toList();

    if (pendingClients.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            "NO PENDING PAYMENTS",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
      );
    }

    final totalClientsDue = pendingClients.fold<double>(
      0.0,
      (sum, c) => sum + c.totalAmountDue,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "CLIENTS DUE (?\${totalClientsDue.toStringAsFixed(0)})",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
            color: SageColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...pendingClients.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    c.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  "?\${c.totalAmountDue.toStringAsFixed(0)} (\${c.dynamicPaymentsDue} mo)",
                  style: const TextStyle(
                    fontSize: 12,
                    color: SageColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  `;
        content = content.substring(0, startIdx) + newMethod + content.substring(endIdx);
        console.log("Found and replaced _buildPendingPaymentsList in " + filePath);
    } else {
      console.log("Could not find start/end idx in " + filePath + " | startIdx: " + startIdx + " | endIdx: " + endIdx);
    }
    
    fs.writeFileSync(filePath, content, 'utf8');
}

processFile('lib/screens/ceo_dashboard.dart');
processFile('lib/screens/cofounder_dashboard.dart');
