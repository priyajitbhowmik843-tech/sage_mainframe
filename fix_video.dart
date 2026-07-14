import 'dart:io';

void main() {
  final scratch = File(r'C:\Users\Priyajit Bhowmik\.gemini\antigravity\brain\7e2e15eb-23c2-4912-b232-ed42e5836f5e\scratch\videographer_dashboard.dart.txt').readAsStringSync();
  
  final fStart1 = scratch.indexOf('    Widget _buildFinanceTab');
  final fStart = scratch.indexOf('    Widget _buildFinanceTab', fStart1 + 1);
  final fEnd = scratch.indexOf('  Widget _buildProfileTab');
  final financeTab = scratch.substring(fStart, fEnd);

  final targetFile = File(r'lib\screens\videographer_dashboard.dart');
  final target = targetFile.readAsStringSync();

  final startIdx = target.indexOf('  Widget _buildSessionApprovalCard');
  final endIdx = target.indexOf('  void _showEditPersonalDetailsDialog');

  final sessionCard = '''  Widget _buildSessionApprovalCard(BuildContext context, AppState state, Task t) {
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

''';

  final profileTab = '''  Widget _buildProfileTab(BuildContext context, AppState state, Persona persona) {
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

''';

  final newContent = target.substring(0, startIdx) + sessionCard + financeTab + profileTab + target.substring(endIdx);
  targetFile.writeAsStringSync(newContent);
  print('Success');
}
