import 'package:flutter/material.dart';
import 'package:sage_mainframe/widgets/team_members_view.dart';
import 'package:provider/provider.dart';
import 'package:sage_mainframe/state/app_state.dart';
import 'package:sage_mainframe/theme/app_theme.dart';
import 'package:sage_mainframe/widgets/common_widgets.dart';
import 'package:sage_mainframe/models/models.dart';
import 'package:sage_mainframe/main.dart';

class VideographerDashboard extends StatefulWidget {
  const VideographerDashboard({super.key});
  @override
  State<VideographerDashboard> createState() => _VideographerDashboardState();
}

class _VideographerDashboardState extends State<VideographerDashboard> {
  int _tab = 0; // 0: Home, 1: Finance, 2: Profile
  DateTime _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDate;

  bool _showPendingSessions = false;
  bool _showPendingMisc = false;

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _tab);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Color _getHeaderColor() {
    switch (_tab) {
      case 0: return SageColors.yellowAccentContainer;
      case 1: return SageColors.primaryContainer;
      case 2: return SageColors.secondaryContainer;
      default: return SageColors.background;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final persona = state.activePersona;

    String title = 'HOME';
    if (_tab == 1) title = 'FINANCE';
    if (_tab == 2) title = 'PROFILE';

    return Scaffold(
      backgroundColor: SageColors.background,
      body: GestureDetector(
          onTap: () { if (_selectedDate != null) setState(() => _selectedDate = null); },
          behavior: HitTestBehavior.translucent,
          child: Stack(
        children: [
          // Header Background colour block
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: _getHeaderColor(),
                border: const Border(bottom: BorderSide(color: Colors.black, width: 1.5)),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top header row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () { context.read<AppState>().logout(); Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginScreen())); },
                        child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: SageColors.yellowAccent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
                        ),
                      ),
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.black)),
                      if (_tab == 2)
                        GestureDetector(
                          onTap: () {
                            final emp = context.read<AppState>().employees.firstWhere(
                              (e) => e.id == persona.id,
                            );
                            _showEditPersonalDetailsDialog(context, emp);
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: SageColors.yellowAccent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 1.5),
                            ),
                            child: const Icon(Icons.edit, color: Colors.black, size: 18),
                          ),
                        )
                      
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 100),
                    child: _buildActiveTab(context, state, persona),
                  ),
                ),
              ],
            ),
          ),
          // Floating yellow pill nav bar
          Positioned(
            bottom: 20, left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: SageColors.yellowAccent,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.black, width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navIcon(0, Icons.calendar_month_outlined, Icons.calendar_month),
                  _navIcon(1, Icons.bar_chart_outlined, Icons.bar_chart),
                  _navIcon(2, Icons.person_outline, Icons.person),
                  _navIcon(3, Icons.group_outlined, Icons.group),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _navIcon(int idx, IconData outline, IconData filled) {
    final active = _tab == idx;
    return GestureDetector(
      onTap: () {
        if (_tab == idx) return;
        setState(() {
          _tab = idx;
          if (idx == 0) {
            _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
            _selectedDate = null;
          }
        });
        try { _pageController.animateToPage(idx, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); } catch (_) {}
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: active ? const BoxDecoration(color: Colors.black, shape: BoxShape.circle) : null,
        child: Icon(active ? filled : outline, color: active ? SageColors.yellowAccent : Colors.black, size: 24),
      ),
    );
  }

  Widget _buildActiveTab(BuildContext context, AppState state, Persona persona) {
    switch (_tab) {
      case 0: return _buildHomeTab(context, state, persona);
      case 1: return _buildFinanceTab(context, state, persona);
      case 2: return _buildProfileTab(context, state, persona);
      case 3: return TeamMembersView();
      default: return const SizedBox();
    }
  }

  // â”€â”€â”€ HOME TAB â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildHomeTab(BuildContext context, AppState state, Persona persona) {
    final myTasks = state.tasks.where((t) => t.assignedTo == persona.id).toList();
    final pendingApprovals = myTasks.where((t) => (t.taskType == 'Session' || t.taskType == 'Miscellaneous Session') && !t.isApprovedByVideographer && !t.isCompleted).toList();
    final miscTasks = myTasks.where((t) => (t.taskType ?? '').toLowerCase() != 'session' && (t.taskType ?? '').toLowerCase() != 'miscellaneous session' && !t.isCompleted).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        _buildCalendar(state, persona),
        const SizedBox(height: 14),
        if (_selectedDate != null) ...[
          _buildSelectedDateInfo(state, persona),
          const SizedBox(height: 14),
        ],
        if (pendingApprovals.isNotEmpty) ...[
          TerminalPanel(
            title: 'PENDING SESSION APPROVALS',
            child: Column(
              children: pendingApprovals.map((t) => _buildSessionApprovalCard(context, state, t)).toList(),
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (miscTasks.isNotEmpty)
          TerminalPanel(
            title: 'OTHER TASKS',
            child: Column(
              children: miscTasks.map((t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(t.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                    Checkbox(
                      value: t.isSubmitted,
                      onChanged: (v) => context.read<AppState>().toggleTask(t.id),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildCalendar(AppState state, Persona persona) {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(_calendarMonth.year, _calendarMonth.month);
    final startOffset = DateTime(_calendarMonth.year, _calendarMonth.month, 1).weekday % 7;
    final mySessionTasks = state.tasks.where((t) => t.assignedTo == persona.id && (t.taskType == 'Session' || t.taskType == 'Miscellaneous Session')).toList();
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
              final regularSessions = sessions.where((t) => t.taskType == 'Session').toList();
              final miscSessions = sessions.where((t) => t.taskType == 'Miscellaneous Session').toList();
              
              final hasCompleted = regularSessions.any((t) => t.isCompleted);
              final hasBooked = regularSessions.any((t) => t.isApprovedByVideographer && !t.isCompleted);
              final hasPending = regularSessions.any((t) => !t.isApprovedByVideographer && !t.isCompleted);

              final hasMiscCompleted = miscSessions.any((t) => t.isCompleted);
              final hasMiscBooked = miscSessions.any((t) => t.isApprovedByVideographer && !t.isCompleted);
              final hasMiscPending = miscSessions.any((t) => !t.isApprovedByVideographer && !t.isCompleted);

              final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
              final isSel = _selectedDate?.year == date.year && _selectedDate?.month == date.month && _selectedDate?.day == date.day;

              Color bgColor = Colors.transparent;
              if (hasCompleted) bgColor = SageColors.primary;
              else if (hasBooked) bgColor = SageColors.tertiary;
              else if (hasPending) bgColor = SageColors.error;
              else if (hasMiscCompleted) bgColor = Colors.blue;
              else if (hasMiscBooked) bgColor = Colors.cyan;
              else if (hasMiscPending) bgColor = Colors.yellow;
              else if (isToday) bgColor = SageColors.yellowAccent;

              if (isSel && (bgColor == Colors.transparent || bgColor == SageColors.yellowAccent)) {
                bgColor = Colors.black;
              }

              Color textColor = (bgColor == SageColors.primary || bgColor == SageColors.tertiary || bgColor == SageColors.error || bgColor == Colors.black || bgColor == Colors.blue) ? Colors.white : Colors.black87;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    if (isSel) {
                      _selectedDate = null;
                    } else {
                      _selectedDate = date;
                    }
                  });
                },
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
                      if (sessions.isNotEmpty)
                        Text(
                          '${sessions.length}x',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            letterSpacing: 0,
                          ),
                        ),
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
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend(Colors.blue, 'Misc Completed'),
              const SizedBox(width: 14),
              _legend(Colors.cyan, 'Misc Booked'),
              const SizedBox(width: 14),
              _legend(Colors.yellow, 'Misc Pending'),
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
      if (t.assignedTo != persona.id || (t.taskType != 'Session' && t.taskType != 'Miscellaneous Session')) return false;
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
          final client = state.clients.where((c) => c.id == t.clientId).firstOrNull;
          final isMisc = t.taskType == 'Miscellaneous Session';
          final statusColor = isMisc
              ? (t.isCompleted ? Colors.blue : t.isApprovedByVideographer ? Colors.cyan : Colors.yellow)
              : (t.isCompleted ? SageColors.primary : t.isApprovedByVideographer ? SageColors.tertiary : SageColors.error);
          
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
                          Text(isMisc ? '${client?.name ?? t.title} (Misc)' : (client?.name ?? 'Unknown Client'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          if (t.isCompleted)
                            Text('Rate: \u20B9${(isMisc ? (t.manualPaymentAmount ?? 0) : (client?.sessionRate ?? 0)).toStringAsFixed(0)}', style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.bold)),
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
    final client = state.clients.where((c) => c.id == t.clientId).firstOrNull;
    final isMisc = t.taskType == 'Miscellaneous Session';
    final amount = isMisc ? (t.manualPaymentAmount ?? 0) : (client?.sessionRate ?? 0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isMisc ? '${client?.name ?? t.title} (Misc)' : (client?.name ?? 'Unknown Client'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text('${t.deadline.day}/${t.deadline.month} | \u20B9${amount.toStringAsFixed(0)}',
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

  // â”€â”€â”€ FINANCE TAB â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
    Widget _buildFinanceTab(BuildContext context, AppState state, Persona persona) {
    final now = DateTime.now();
    final myTasks = state.tasks.where((t) => t.assignedTo == persona.id && (t.taskType == 'Session' || t.taskType == 'Miscellaneous Session')).toList();
    final monthSessions = myTasks.where((t) => t.deadline.year == now.year && t.deadline.month == now.month).toList();
    final completedThisMonth = monthSessions.where((t) => t.isCompleted).length;
    
    final completedSessions = myTasks.where((t) => t.isCompleted).toList();

    double collectedAmount = 0;
    for (final t in completedSessions.where((x) => x.isPaymentAcknowledgedByVideographer)) {
      if (t.taskType == 'Miscellaneous Session') {
        collectedAmount += t.manualPaymentAmount ?? 0;
      } else {
        final c = state.clients.where((c) => c.id == t.clientId).firstOrNull;
        if (c != null) collectedAmount += c.sessionRate;
      }
    }
    
    double pendingAmount = 0;
    for (final t in completedSessions.where((x) => !x.isPaymentAcknowledgedByVideographer)) {
      if (t.taskType == 'Miscellaneous Session') {
        pendingAmount += t.manualPaymentAmount ?? 0;
      } else {
        final c = state.clients.where((c) => c.id == t.clientId).firstOrNull;
        if (c != null) pendingAmount += c.sessionRate;
      }
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
                final client = state.clients.where((c) => c.id == t.clientId).firstOrNull;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text((t.taskType == 'Miscellaneous Session') ? '${client?.name ?? t.title} (Misc)' : (client?.name ?? 'Unknown Client'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            Text('${t.title} | \u20B9${(t.taskType == 'Miscellaneous Session' ? (t.manualPaymentAmount ?? 0) : (client?.sessionRate ?? 0)).toStringAsFixed(0)}',
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
                        ),
                        onPressed: () {
                          context.read<AppState>().acknowledgeVideographerPayment(t.id);
                        },
                        child: const Text('MARK PAID'),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
        ],

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
                        Text('\u20B9${c.sessionRate.toStringAsFixed(0)} / session',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: SageColors.primary)),
                      ],
                    ),
                  );
                }).toList(),
              );
            }
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // Remove the old _isPaymentApproved since we don't need it.
  
  Widget _buildProfileTab(BuildContext context, AppState state, Persona persona) {
    final emp = state.employees.firstWhere((e) => e.id == persona.id);
    final isVideoEditor = emp.role.toLowerCase().contains('video editor');
    
    // Dynamic fetching of tasks based on whether CEO has cleared the payment or not
    final relevantTasks = state.tasks.where((t) {
      if (t.assignedTo != emp.id) return false;
      if (!t.isCompleted) return false;
      if (!isVideoEditor && t.taskType != 'Session' && t.taskType != 'Miscellaneous Session') return false;
      
      return (!t.isPaidToVideographer) || (t.isPaidToVideographer && !t.isPaymentAcknowledgedByVideographer);
    }).toList();

    final regularSessions = relevantTasks.where((t) => t.taskType == 'Session' || (isVideoEditor && t.taskType != 'Miscellaneous Session')).toList();
    final miscSessions = relevantTasks.where((t) => t.taskType == 'Miscellaneous Session').toList();

    double pendingRegularPayout = 0;
    for (var t in regularSessions) {
      if (isVideoEditor) {
        pendingRegularPayout += emp.perSessionRate;
      } else {
        final c = state.clients.where((client) => client.id == t.clientId).firstOrNull;
        if (c != null) pendingRegularPayout += c.sessionRate;
      }
    }

    double pendingMiscPayout = 0;
    for (var t in miscSessions) {
      if (t.manualPaymentAmount != null && t.manualPaymentAmount! > 0) {
        pendingMiscPayout += t.manualPaymentAmount!;
      }
    }

    double totalPendingPayout = pendingRegularPayout + pendingMiscPayout;
    if (emp.paymentCleared && emp.pendingPayAmount > totalPendingPayout) {
      totalPendingPayout = emp.pendingPayAmount;
    }

    final legacyMiscStrings = (emp.pendingPayMonth ?? '').split(',').map((s) => s.trim()).where((s) => s.startsWith('Misc')).toList();
    final legacyRegularStrings = (emp.pendingPayMonth ?? '').split(',').map((s) => s.trim()).where((s) => s.startsWith('Sessions')).toList();

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
                    child: Transform.scale(scale: 1.7, child: Image.asset(availableAvatars[emp.avatar % availableAvatars.length], fit: BoxFit.cover, width: 140, height: 140)),
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
              _profileRow("PENDING PAYOUT", "\u20B9${totalPendingPayout.toStringAsFixed(0)}"),
              
              if (regularSessions.isNotEmpty || (emp.paymentCleared && legacyRegularStrings.isNotEmpty))
                Column(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _showPendingSessions = !_showPendingSessions),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("REGULAR SESSIONS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                            Row(
                              children: [
                                Text("${regularSessions.isNotEmpty ? regularSessions.length : legacyRegularStrings.length} ( \u20B9${regularSessions.isNotEmpty ? pendingRegularPayout.toStringAsFixed(0) : '--'} )", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                                Icon(_showPendingSessions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 20),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_showPendingSessions)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          children: regularSessions.isNotEmpty
                            ? regularSessions.map((t) {
                            final c = state.clients.where((client) => client.id == t.clientId).firstOrNull;
                            final rate = isVideoEditor ? emp.perSessionRate : (c?.sessionRate ?? 0);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(c?.name ?? t.title, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                  Text("\u20B9${rate.toStringAsFixed(0)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          }).toList() : legacyRegularStrings.map((s) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(s, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                      const Text("\u20B9--", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                  ],
                ),
                
              if (miscSessions.isNotEmpty || (emp.paymentCleared && legacyMiscStrings.isNotEmpty))
                Column(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _showPendingMisc = !_showPendingMisc),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("MISC SESSIONS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                            Row(
                              children: [
                                Text("${miscSessions.isNotEmpty ? miscSessions.length : legacyMiscStrings.length} ( \u20B9${miscSessions.isNotEmpty ? pendingMiscPayout.toStringAsFixed(0) : '--'} )", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                                Icon(_showPendingMisc ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 20),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_showPendingMisc)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          children: miscSessions.isNotEmpty
                            ? miscSessions.map((t) {
                            final rate = t.manualPaymentAmount ?? 0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(t.title, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                  Text("\u20B9${rate.toStringAsFixed(0)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          }).toList() : legacyMiscStrings.map((s) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(s, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                                      const Text("\u20B9--", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                  ],
                ),
                
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: emp.paymentCleared
                      ? () {
                          // Acknowledge all pending tasks dynamically along with clearing the status
                          for (var t in relevantTasks) {
                            if (t.isPaidToVideographer && !t.isPaymentAcknowledgedByVideographer) {
                              context.read<AppState>().acknowledgeVideographerPayment(t.id);
                            }
                          }
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
  void _showEditPersonalDetailsDialog(BuildContext context, Employee emp) {
    final nameCtrl = TextEditingController(text: emp.name);
    final addressCtrl = TextEditingController(text: emp.address);
    final phoneCtrl = TextEditingController(text: emp.phone);
    final emailCtrl = TextEditingController(text: emp.email);
    final prefNameCtrl = TextEditingController(text: emp.preferredName);
    final emergencyCtrl = TextEditingController(text: emp.emergencyContact);
    final bioCtrl = TextEditingController(text: emp.professionalBio);
    final interestsCtrl = TextEditingController(text: emp.interests);
    
    String selectedWorkLocation = emp.workLocation.isEmpty ? 'Office' : emp.workLocation;
    String selectedWorkStyle = emp.workStylePreference.isEmpty ? 'Independent thinker' : emp.workStylePreference;
    List<String> selectedSkills = List.from(emp.keySkills);
    List<String> selectedStrengths = List.from(emp.strengths);

    int selectedAvatar = emp.avatar;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: SageColors.background,
              title: const Text("EDIT PERSONAL DETAILS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SageTextField(controller: nameCtrl, label: "Name"),
                    const SizedBox(height: 10),
                    SageTextField(controller: addressCtrl, label: "Address"),
                    const SizedBox(height: 10),
                    SageTextField(controller: phoneCtrl, label: "Phone"),
                    const SizedBox(height: 10),
                    SageTextField(controller: emailCtrl, label: "Email"),
                    const SizedBox(height: 10),
                    SageTextField(controller: prefNameCtrl, label: "Preferred Name"),
                    const SizedBox(height: 10),
                    SageTextField(controller: emergencyCtrl, label: "Emergency Contact"),
                    const SizedBox(height: 10),
                    SageTextField(controller: bioCtrl, label: "Professional Bio", maxLines: 3),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedWorkLocation,
                      decoration: const InputDecoration(labelText: "Work Location"),
                      items: ['Office', 'Remote', 'Hybrid'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => selectedWorkLocation = v ?? 'Office'),
                      dropdownColor: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedWorkStyle,
                      decoration: const InputDecoration(labelText: "Work Style Preference"),
                      items: ['Independent thinker', 'Team collaborator', 'Detail-oriented', 'Fast executor', 'Strategic planner'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => selectedWorkStyle = v ?? 'Independent thinker'),
                      dropdownColor: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    SageTextField(controller: interestsCtrl, label: "Interests / Hobbies"),
                    const SizedBox(height: 10),
                    const Text("KEY SKILLS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: ['Editing', 'Sales', 'Design', 'Marketing', 'Coding'].map((skill) {
                        final isSelected = selectedSkills.contains(skill);
                        return FilterChip(
                          label: Text(skill, style: const TextStyle(fontSize: 10)),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                selectedSkills.add(skill);
                              } else {
                                selectedSkills.remove(skill);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    const Text("STRENGTHS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: ['Leadership', 'Problem Solving', 'Creativity', 'Communication'].map((strength) {
                        final isSelected = selectedStrengths.contains(strength);
                        return FilterChip(
                          label: Text(strength, style: const TextStyle(fontSize: 10)),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                selectedStrengths.add(strength);
                              } else {
                                selectedStrengths.remove(strength);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text("CHOOSE AVATAR", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: List.generate(availableAvatars.length, (index) {
                        final isSelected = selectedAvatar == index;
                        return GestureDetector(
                          onTap: () => setState(() => selectedAvatar = index),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? SageColors.primary : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 1.5),
                            ),
                            child: ClipOval(child: Transform.scale(scale: 1.7, child: Image.asset(availableAvatars[index], fit: BoxFit.cover, width: 48, height: 48))),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: SageColors.primary),
                  onPressed: () {
                    context.read<AppState>().updateEmployee(
                      emp.id,
                      name: nameCtrl.text,
                      address: addressCtrl.text,
                      phone: phoneCtrl.text,
                      email: emailCtrl.text,
                      avatar: selectedAvatar,
                      preferredName: prefNameCtrl.text,
                      emergencyContact: emergencyCtrl.text,
                      professionalBio: bioCtrl.text,
                      workLocation: selectedWorkLocation,
                      workStylePreference: selectedWorkStyle,
                      interests: interestsCtrl.text,
                      keySkills: selectedSkills,
                      strengths: selectedStrengths,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text("SAVE"),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _profileRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: SageColors.onSurfaceVariant)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)),
        ],
      ),
    );
  }
}









