  Widget _buildCalendar(AppState state, Persona persona) {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(_calendarMonth.year, _calendarMonth.month);
    final startOffset = DateTime(_calendarMonth.year, _calendarMonth.month, 1).weekday % 7;
    final mySessionTasks = state.tasks.where((t) => t.assignedTo == persona.id && t.taskType == 'Session').toList();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => setState(() => _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month - 1, 1)),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: SageColors.yellowAccent, shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 1.5)),
                  child: const Icon(Icons.chevron_left, size: 18),
                ),
              ),
              Text('${months[_calendarMonth.month-1]} ${_calendarMonth.year}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
              GestureDetector(
                onTap: () => setState(() => _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 1)),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: SageColors.yellowAccent, shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 1.5)),
                  child: const Icon(Icons.chevron_right, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: ['S','M','T','W','T','F','S'].map((d) => Expanded(
              child: Center(child: Text(d, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54))),
            )).toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
            itemCount: daysInMonth + startOffset,
            itemBuilder: (ctx, i) {
              if (i < startOffset) return const SizedBox();
              final day = i - startOffset + 1;
              final date = DateTime(_calendarMonth.year, _calendarMonth.month, day);
              final sessions = mySessionTasks.where((t) {
                final dd = t.deadline;
                return dd.year == date.year && dd.month == date.month && dd.day == date.day;
              }).toList();
              final hasBooked = sessions.any((t) => t.isApprovedByVideographer && !t.isCompleted);
              final hasPending = sessions.any((t) => !t.isApprovedByVideographer && !t.isCompleted);
              final hasCompleted = sessions.any((t) => t.isCompleted);
              final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
              final isSel = _selectedDate?.year == date.year && _selectedDate?.month == date.month && _selectedDate?.day == date.day;

              Color bgColor = Colors.transparent;
              if (hasCompleted) bgColor = SageColors.primary;
              else if (hasBooked) bgColor = SageColors.tertiary;
              else if (hasPending) bgColor = SageColors.error;
              else if (isToday) bgColor = SageColors.yellowAccent;

              if (isSel && (bgColor == Colors.transparent || bgColor == SageColors.yellowAccent)) {
                bgColor = Colors.black;
              }

              Color textColor = (bgColor == SageColors.primary || bgColor == SageColors.tertiary || bgColor == SageColors.error || bgColor == Colors.black) ? Colors.white : Colors.black87;

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: isSel ? 2.5 : 1.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('$day', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
                          color: textColor)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend(SageColors.primary, 'Completed'),
              const SizedBox(width: 14),
              _legend(SageColors.tertiary, 'Booked'),
              const SizedBox(width: 14),
              _legend(SageColors.error, 'Pending'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color c, String label) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 0.5))),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
  ]);

  Widget _buildSelectedDateInfo(AppState state, Persona persona) {
    final d = _selectedDate!;
    final sessions = state.tasks.where((t) {
      if (t.assignedTo != persona.id || t.taskType != 'Session') return false;
      final dd = t.deadline;
      return dd.year == d.year && dd.month == d.month && dd.day == d.day;
    }).toList();

    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateLabel = '${d.day} ${months[d.month-1]} ${d.year}';

    if (sessions.isEmpty) {
      return TerminalPanel(
        title: dateLabel.toUpperCase(),
        child: const Text('No sessions on this date.', style: TextStyle(color: Colors.black54, fontSize: 12)),
      );
    }

    return TerminalPanel(
      title: dateLabel.toUpperCase(),
      child: Column(
        children: sessions.map((t) {
          final client = state.clients.firstWhereOrNull((c) => c.id == t.clientId);
          final statusColor = t.isCompleted ? SageColors.primary : t.isApprovedByVideographer ? SageColors.tertiary : SageColors.error;
          
          String statusText = t.isCompleted ? 'COMPLETED' : t.isApprovedByVideographer ? 'CONFIRMED' : 'PENDING APPROVAL';
          if (t.isSubmitted && !t.isCompleted) statusText = 'COMPLETION REQUESTED';
          if (t.isPostponeRequested) statusText = 'POSTPONE REQUESTED TO ${t.postponeRequestedDate?.day}/${t.postponeRequestedDate?.month}';

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SageColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(width: 4, height: 44, decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(client?.name ?? 'Unknown Client', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          if (t.isCompleted && client != null)
                            Text('Rate: \u20B9${client?.sessionRate.toStringAsFixed(0) ?? 0}', style: TextStyle(fontSize: 11, color: SageColors.primary, fontWeight: FontWeight.bold)),
                          Text(statusText, style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                    Icon(t.isCompleted ? Icons.check_circle : t.isApprovedByVideographer ? Icons.videocam : Icons.hourglass_top,
                        color: statusColor, size: 20),
                  ],
                ),
                if (!t.isCompleted && !t.isSubmitted && !t.isPostponeRequested && t.isApprovedByVideographer) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          side: const BorderSide(color: Colors.black),
                        ),
                        onPressed: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: t.deadline,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selected != null) {
                            context.read<AppState>().requestPostponeTask(t.id, selected);
                          }
                        },
                        child: const Text('POSTPONE'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SageColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => context.read<AppState>().submitTask(t.id),
                        child: const Text('COMPLETE'),
                      ),
                    ],
                  )
                ]
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSessionApprovalCard(BuildContext context, AppState state, Task t) {
    final client = state.clients.firstWhereOrNull((c) => c.id == t.clientId);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(client?.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text('//',
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

  // ─── FINANCE TAB ─────────────────────────────────────────────────────────
    Widget _buildFinanceTab(BuildContext context, AppState state, Persona persona) {
    final now = DateTime.now();
    final myTasks = state.tasks.where((t) => t.assignedTo == persona.id && t.taskType == 'Session').toList();
    final monthSessions = myTasks.where((t) => t.deadline.year == now.year && t.deadline.month == now.month).toList();
    final completedThisMonth = monthSessions.where((t) => t.isCompleted).length;
    
    final completedSessions = myTasks.where((t) => t.isCompleted).toList();

    double collectedAmount = 0;
    for (final t in completedSessions.where((x) => x.isPaymentAcknowledgedByVideographer)) {
      final c = state.clients.firstWhereOrNull((c) => c.id == t.clientId);
      if (c != null) collectedAmount += c.sessionRate;
    }
    
    double pendingAmount = 0;
    for (final t in completedSessions.where((x) => !x.isPaymentAcknowledgedByVideographer)) {
      final c = state.clients.firstWhereOrNull((c) => c.id == t.clientId);
      if (c != null) pendingAmount += c.sessionRate;
    }
    
    final sessionsPendingApproval = completedSessions.where((t) => t.isPaidToVideographer && !t.isPaymentAcknowledgedByVideographer).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        TerminalPanel(
          title: 'MONTHLY OVERVIEW',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: StatChip(label: 'SESSIONS THIS MONTH', value: '$completedThisMonth', valueColor: SageColors.primary, icon: Icons.check_circle)),
                  const SizedBox(width: 12),
                  Expanded(child: StatChip(label: 'PAYMENT PENDING', value: '\u20B9${pendingAmount.toStringAsFixed(0)}', valueColor: SageColors.error, icon: Icons.pending)),
                ],
              ),
              const SizedBox(height: 12),
              StatChip(label: 'AMOUNT COLLECTED', value: '\u20B9${collectedAmount.toStringAsFixed(0)}', valueColor: SageColors.tertiary, icon: Icons.currency_rupee),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (sessionsPendingApproval.isNotEmpty) ...[
          TerminalPanel(
            title: 'PAYMENT PENDING APPROVAL',
            child: Column(
              children: sessionsPendingApproval.map((t) {
                final client = state.clients.firstWhereOrNull((c) => c.id == t.clientId);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(client?.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Text('${t.title} | \u20B9${client?.sessionRate.toStringAsFixed(0) ?? 0}',
                                style: const TextStyle(fontSize: 11, color: Colors.black54)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SageColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
