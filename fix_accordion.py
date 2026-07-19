import sys

def process_file(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    
    # 1. Replace TerminalPanel wrapping pending payments
    old_panel = """        TerminalPanel(
          title: "PENDING PAYMENTS",
          child: _buildPendingPaymentsList(state),
        ),"""
        
    new_panel = """        Container(
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
        ),"""
        
    content = content.replace(old_panel, new_panel)
    
    # 2. Replace _buildPendingPaymentsList
    start_idx = content.find("  Widget _buildPendingPaymentsList(AppState state) {")
    end_idx = content.find("  Widget _buildNotificationsPanel(AppState state) {")
    if end_idx == -1:
        # Maybe different in cofounder
        end_idx = content.find("  Widget _buildNotificationPanel(AppState state) {")
    
    if start_idx != -1 and end_idx != -1:
        new_method = """  Widget _buildPendingPaymentsList(AppState state) {
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
          "CLIENTS DUE (?${totalClientsDue.toStringAsFixed(0)})",
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
                  "?${c.totalAmountDue.toStringAsFixed(0)} (${c.dynamicPaymentsDue} mo)",
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

"""
        content = content[:start_idx] + new_method + content[end_idx:]
    
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Updated {file_path}")

process_file('lib/screens/ceo_dashboard.dart')
process_file('lib/screens/cofounder_dashboard.dart')
