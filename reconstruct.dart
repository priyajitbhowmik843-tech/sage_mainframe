import 'dart:io';

void main() {
  final file = File('lib/screens/employee_dashboard.dart');
  final lines = file.readAsLinesSync();

  final out = <String>[];
  bool injected = false;

  for (int i = 0; i < lines.length; i++) {
    if (lines[i].contains(
      "final pendingApprovals = myTasks.where((t) => t.taskType == 'Session'",
    )) {
      out.add(lines[i]);
      if (!injected) {
        out.add(r'''
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        const LiveClockWidget(),
        const SizedBox(height: 10),
        
        if (isVideographer) ...[
          _buildCalendar(state, persona),
          const SizedBox(height: 14),
          _buildSelectedDateInfo(state, persona),
          const SizedBox(height: 14),
          if (pendingApprovals.isNotEmpty) ...[
            TerminalPanel(
              title: 'PENDING SESSION APPROVALS',
              child: Column(
                children: pendingApprovals.map((t) => _buildSessionApprovalCard(context, state, t)).toList(),
              ),
            ),
            const SizedBox(height: 14),
          ],
        ],

        TerminalPanel(
          title: "SAGE OS METRICS",
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _switchTab(1),
                      child: StatChip(
                        label: "PENDING TASKS",
                        value: "$pendingCount",
                        valueColor: SageColors.primary,
                        icon: Icons.assignment_late,
                        showBadge: pendingCount > 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatChip(
                      label: "APPROVED TODAY",
                      value: "$approvedTodayCount",
                      valueColor: SageColors.tertiary,
                      icon: Icons.check_circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _switchTab(1),
                      child: StatChip(
                        label: "OVERDUE TASKS",
                        value: "$overdueCount",
                        valueColor: SageColors.error,
                        icon: Icons.warning_amber_rounded,
                        showBadge: overdueCount > 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _switchTab(1),
                      child: StatChip(
                        label: "REJECTED TODAY",
                        value: "$rejectedTodayCount",
                        valueColor: SageColors.secondary,
                        icon: Icons.cancel_outlined,
                        showBadge: rejectedTodayCount > 0,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Motivational card styled neo-brutalist
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SageColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.black, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "WELCOME BACK, ${state.activePersona.name}!",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Keep pushing your daily targets.",
                            style: TextStyle(fontSize: 10, color: SageColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        TerminalPanel(
          title: "TASK SUMMARY",
          child: Container(
            height: 250,''');
        injected = true;
      }
    } else {
      out.add(lines[i]);
    }
  }

  file.writeAsStringSync(out.join('\n'));
  print('done');
}
