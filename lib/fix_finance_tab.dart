import 'dart:io';

void main() {
  final file = File('lib/screens/videographer_dashboard.dart');
  String content = file.readAsStringSync();

  final startStr = 'Widget _buildFinanceTab';
  final endStr = 'Widget _buildProfileTab';

  final startIndex = content.indexOf(startStr);
  final endIndex = content.indexOf(endStr);

  if (startIndex != -1 && endIndex != -1) {
    final cleanFinanceTab =
        '''Widget _buildFinanceTab(BuildContext context, AppState state, Persona persona) {
    final now = DateTime.now();
    final myTasks = state.tasks.where((t) => t.assignedTo == persona.id && t.taskType == 'Session').toList();
    final monthSessions = myTasks.where((t) => t.deadline.year == now.year && t.deadline.month == now.month).toList();
    final completedThisMonth = monthSessions.where((t) => t.isCompleted).length;

    final emp = state.employees.firstWhere((e) => e.id == persona.id);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: InfoCard(
                title: 'SESSIONS\\nTHIS MONTH',
                value: '\$completedThisMonth',
                subtitle: 'COMPLETED',
                color: SageColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InfoCard(
                title: 'PENDING\\nPAYMENT',
                value: '\\u20B9\${emp.pendingPayAmount.toStringAsFixed(0)}',
                subtitle: 'FOR \${emp.pendingPayMonth ?? "N/A"}',
                color: SageColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TerminalPanel(
          title: 'MY CLIENTS',
          child: Builder(
            builder: (ctx) {
              final myClients = state.clients.where((c) => c.assignedVideographerId == persona.id).toList();
              if (myClients.isEmpty) {
                return const Text('No clients currently assigned.', style: TextStyle(color: Colors.black54, fontSize: 12));
              }
              return Column(
                children: myClients.map((c) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        Text('\\u20B9\${c.sessionRate.toStringAsFixed(0)} / session',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: SageColors.primary)),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  ''';

    content = content.replaceRange(startIndex, endIndex, cleanFinanceTab);
    file.writeAsStringSync(content);
    print("Fixed videographer finance tab!");
  } else {
    print("Could not find boundaries!");
  }
}
