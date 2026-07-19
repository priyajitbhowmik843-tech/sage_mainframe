const fs = require('fs');

function fixDashboard(filePath) {
    let code = fs.readFileSync(filePath, 'utf8');

    // Replace TerminalPanel with ExpansionTile
    code = code.replace(
        /TerminalPanel\(\s*title:\s*"PENDING PAYMENTS",\s*child:\s*_buildPendingPaymentsList\(state\),\s*\)/g,
        `Container(
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
        )`
    );

    // Replace the _buildPendingPaymentsList content
    // We need to completely remove pendingEmployees, and change the return of the list.
    const startIdx = code.indexOf('Widget _buildPendingPaymentsList(AppState state) {');
    const endIdx = code.indexOf('Widget _buildNotificationsPanel(AppState state) {');
    
    if (startIdx !== -1 && endIdx !== -1) {
        const newMethod = `Widget _buildPendingPaymentsList(AppState state) {
    final pendingClients = state.clients
        .where((c) => (c.status == 'Active' || c.status == 'Retained') && c.dynamicPaymentsDue > 0)
        .toList();

    if (pendingClients.isEmpty) {
      return const Center(
        child: Text(
          "NO PENDING PAYMENTS",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      );
    }

    final totalClientsDue = pendingClients.fold<double>(0.0, (sum, c) => sum + c.totalAmountDue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "CLIENTS DUE (?\${totalClientsDue.toStringAsFixed(0)})",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: SageColors.primary),
        ),
        const SizedBox(height: 8),
        ...pendingClients.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  c.name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "?\${c.totalAmountDue.toStringAsFixed(0)} (\${c.dynamicPaymentsDue} mo)",
                style: const TextStyle(fontSize: 12, color: SageColors.error, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        )),
      ],
    );
  }

  `;
        
        // Wait, in cofounder dashboard, it might be followed by _buildNotificationPanel instead of _buildNotificationsPanel
        // Let's use a simpler regex or manual string slice.
    }
}

// Better to do a more robust regex replacement for the method
function replaceMethod(filePath, methodStart, methodEndStr, newMethodStr) {
    let code = fs.readFileSync(filePath, 'utf8');
    const startIdx = code.indexOf(methodStart);
    if (startIdx === -1) return;
    const endIdx = code.indexOf(methodEndStr, startIdx);
    if (endIdx === -1) return;
    
    code = code.substring(0, startIdx) + newMethodStr + code.substring(endIdx);
    
    // Also replace the TerminalPanel call
    code = code.replace(
        /TerminalPanel\(\s*title:\s*"PENDING PAYMENTS",\s*child:\s*_buildPendingPaymentsList\(state\),\s*\)/g,
        `Container(
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
        )`
    );

    fs.writeFileSync(filePath, code, 'utf8');
    console.log(`Updated ${filePath}`);
}

const newMethod = `Widget _buildPendingPaymentsList(AppState state) {
    final pendingClients = state.clients
        .where((c) => (c.status == 'Active' || c.status == 'Retained') && c.dynamicPaymentsDue > 0)
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

    final totalClientsDue = pendingClients.fold<double>(0.0, (sum, c) => sum + c.totalAmountDue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "CLIENTS DUE (?\${totalClientsDue.toStringAsFixed(0)})",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: SageColors.primary),
        ),
        const SizedBox(height: 8),
        ...pendingClients.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  c.name,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "?\${c.totalAmountDue.toStringAsFixed(0)} (\${c.dynamicPaymentsDue} mo)",
                style: const TextStyle(fontSize: 12, color: SageColors.error, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        )),
      ],
    );
  }

  `;

replaceMethod('lib/screens/ceo_dashboard.dart', 'Widget _buildPendingPaymentsList(AppState state) {', 'Widget _buildNotificationsPanel(AppState state) {', newMethod);
replaceMethod('lib/screens/cofounder_dashboard.dart', 'Widget _buildPendingPaymentsList(AppState state) {', 'Widget _buildNotificationsPanel(AppState state) {', newMethod);

