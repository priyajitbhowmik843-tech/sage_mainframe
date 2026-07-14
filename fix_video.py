import sys

with open(r'C:\Users\Priyajit Bhowmik\.gemini\antigravity\brain\7e2e15eb-23c2-4912-b232-ed42e5836f5e\scratch\videographer_dashboard.dart.txt', 'r', encoding='utf-8') as f:
    scratch_content = f.read()

# Extract the CLEAN finance tab from scratch file
f_start = scratch_content.find('    Widget _buildFinanceTab')
f_start = scratch_content.find('    Widget _buildFinanceTab', f_start + 1)
f_end = scratch_content.find('  Widget _buildProfileTab')
finance_tab = scratch_content[f_start:f_end]

with open(r'lib\screens\videographer_dashboard.dart', 'r', encoding='utf-8') as f:
    target = f.read()

start_idx = target.find('  Widget _buildSessionApprovalCard')
end_idx = target.find('  void _showEditPersonalDetailsDialog')

if start_idx == -1 or end_idx == -1:
    print('Failed to find start or end index')
    sys.exit(1)

session_card = '''  Widget _buildSessionApprovalCard(BuildContext context, AppState state, Task t) {
    final client = state.clients.where((c) => c.id == t.clientId).firstOrNull;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(client?.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text('\ | ?\',
                    style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SageColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            onPressed: () => context.read<AppState>().approveVideographerSession(t.id),
            child: const Text('APPROVE'),
          ),
        ],
      ),
    );
  }

'''

profile_tab = '''  Widget _buildProfileTab(BuildContext context, AppState state, Persona persona) {
    final emp = state.employees.firstWhere((e) => e.id == persona.id);
    final isVideoEditor = emp.role.toLowerCase().contains('video editor');
    final unpaidSessionsList = state.tasks.where((t) => t.assignedTo == emp.id && (isVideoEditor ? true : t.taskType == 'Session') && t.isCompleted && !t.isPaidToVideographer).toList();
    final int unpaidSessionsCount = unpaidSessionsList.length;
    
    double pendingPayout = 0;
    for (var t in unpaidSessionsList) {
      if (isVideoEditor) {
        pendingPayout += emp.perSessionRate;
      } else {
        final c = state.clients.where((client) => client.id == t.clientId).firstOrNull;
        if (c != null) {
          pendingPayout += c.sessionRate;
        }
      }
    }

    final displayPayout = emp.paymentCleared ? emp.pendingPayAmount : pendingPayout;
    final displaySessions = emp.paymentCleared ? (emp.pendingPayMonth ?? "\") : "\";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        TerminalPanel(
          title: "ACCOUNT DATA",
          child: Column(
            children: [
              Center(
                  child: ClipOval(
                    child: Image.asset(availableAvatars[emp.avatar % availableAvatars.length], fit: BoxFit.cover, width: 140, height: 140),
                  ),
                ),
              const SizedBox(height: 16),
              _profileRow("NAME", emp.name),
              _profileRow("ROLE", persona.roleLabel),
              _profileRow("ID CODE", persona.id),
              _profileRow("PASSWORD", emp.password),
              _profileRow("ADDRESS", emp.address.isNotEmpty ? emp.address : '---'),
              _profileRow("PHONE", emp.phone.isNotEmpty ? emp.phone : '---'),
              _profileRow("EMAIL", emp.email.isNotEmpty ? emp.email : '---'),
              const SizedBox(height: 24),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        TerminalPanel(
          title: "FINANCE DATA",
          child: Column(
            children: [
              _profileRow("PENDING PAYOUT", "?\"),
              _profileRow("UNPAID SESSIONS", displaySessions),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: emp.paymentCleared
                      ? () {
                          context.read<AppState>().toggleEmployeePaymentApproved(emp.id, true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Payment Receipt Confirmed!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: emp.paymentCleared ? SageColors.primary : Colors.grey.shade300,
                    foregroundColor: emp.paymentCleared ? Colors.white : Colors.grey.shade600,
                  ),
                  child: Text(emp.paymentCleared ? "RECEIVE PAYMENT" : "WAITING FOR PAYMENT"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

'''

new_content = target[:start_idx] + session_card + finance_tab + profile_tab + target[end_idx:]

with open(r'lib\screens\videographer_dashboard.dart', 'w', encoding='utf-8') as f:
    f.write(new_content)

print('Success!')
