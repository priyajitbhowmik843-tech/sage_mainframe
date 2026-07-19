import 'package:flutter/material.dart';
import 'package:sage_mainframe/widgets/team_members_view.dart';
import 'package:provider/provider.dart';
import 'package:sage_mainframe/state/app_state.dart';
import 'package:sage_mainframe/theme/app_theme.dart';
import 'package:sage_mainframe/widgets/common_widgets.dart';
import 'package:sage_mainframe/models/models.dart';
import 'package:sage_mainframe/main.dart';
import 'package:sage_mainframe/screens/client_resources_screen.dart';
import 'package:collection/collection.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  // 0: Home, 1: Activity, 2: Clients, 3: Profile
  int _tab = 0;
  late PageController _pageController;
  DateTime? _selectedDate = DateTime.now();
  
  // Calendar State
  DateTime _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedCalendarDate;
  bool _isAddTaskExpanded = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _tab);
    _selectedCalendarDate = DateTime.now();
  }

  Color _getHeaderColor() {
    switch (_tab) {
      case 0: return SageColors.yellowAccentContainer;
      case 1: return SageColors.primaryContainer;
      case 2: return SageColors.tertiaryContainer;
      case 3: return SageColors.secondaryContainer;
      default: return SageColors.background;
    }
  }

  String _getTitle() {
    switch (_tab) {
      case 0: return 'HOME';
      case 1: return 'ACTIVITY';
      case 2: return 'CLIENTS';
      case 3: return 'PROFILE';
      default: return 'HOME';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final persona = state.activePersona;

    return WillPopScope(
      onWillPop: () async {
        if (_tab != 0) {
          setState(() => _tab = 0);
          return false;
        }
        return true;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() {
            _selectedCalendarDate = null;
            _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
          });
        },
        behavior: HitTestBehavior.translucent,
        child: Scaffold(
          backgroundColor: SageColors.background,
          body: Stack(
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
                          Text(_getTitle(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.black)),
                          if (_tab == 3)
                            GestureDetector(
                              onTap: () {
                                final emp = context.read<AppState>().employees.firstWhereOrNull(
                                  (e) => e.id == persona.id,
                                );
                                if (emp != null) {
                                  _showEditPersonalDetailsDialog(context, emp);
                                }
                              },
                              child: Container(
                                width: 38, height: 38,
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
                      _navIcon(0, Icons.home_outlined, Icons.home),
                      _navIcon(1, Icons.bar_chart_outlined, Icons.bar_chart),
                      _navIcon(2, Icons.grid_view_outlined, Icons.grid_view),
                      _navIcon(3, Icons.person_outline, Icons.person),
                      _navIcon(4, Icons.group_outlined, Icons.group),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navIcon(int idx, IconData outline, IconData filled) {
    final active = _tab == idx;
    return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
      if (_tab == idx) return;
      setState(() {
        _tab = idx;
        if (idx == 1) {
          _selectedDate = DateTime.now();
          _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
        }
      });
      _pageController.jumpToPage(idx);
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
      case 1: return _buildActivityTab(context, state, persona);
      case 2: return const ClientResourcesScreen(readOnly: true);
      case 3: return _buildProfileTab(context, state, persona);
      case 4: return TeamMembersView();
      default: return const SizedBox();
    }
  }

  // â”€â”€â”€ TAB 0: HOME â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildHomeTab(BuildContext context, AppState state, Persona persona) {
    final now = DateTime.now();
    final myTasks = state.tasks.where((t) => t.assignedTo == persona.id).toList();

    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final pendingTasks = myTasks.where((t) => !t.isCompleted).toList();
    final overdueTasks = myTasks.where((t) => !t.isCompleted && t.deadline.isBefore(todayStart)).toList();
    final approvedToday = myTasks.where((t) =>
      t.isCompleted &&
      t.deadline.year == now.year &&
      t.deadline.month == now.month &&
      t.deadline.day == now.day
    ).toList();
    final rejectedToday = myTasks.where((t) =>
      t.isSubmitted && !t.isCompleted &&
      t.deadline.year == now.year &&
      t.deadline.month == now.month &&
      t.deadline.day == now.day
    ).toList();

    // Upcoming tasks: not completed, deadline in future
    final upcomingTasks = myTasks.where((t) => !t.isCompleted && t.deadline.isAfter(todayEnd)).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        const LiveClockWidget(),
        const SizedBox(height: 10),

        // SAGE OS METRICS panel
        TerminalPanel(
          title: 'SAGE OS METRICS',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatChip(
                      label: 'PENDING TASKS',
                      value: '${pendingTasks.length}',
                      valueColor: SageColors.primary,
                      icon: Icons.assignment_late,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatChip(
                      label: 'APPROVED TODAY',
                      value: '${approvedToday.length}',
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
                    child: StatChip(
                      label: 'OVERDUE TASKS',
                      value: '${overdueTasks.length}',
                      valueColor: SageColors.error,
                      icon: Icons.warning_amber_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatChip(
                      label: 'REJECTED TODAY',
                      value: '${rejectedToday.length}',
                      valueColor: SageColors.error,
                      icon: Icons.cancel_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Welcome Banner
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
                            'WELCOME BACK, ${persona.name.toUpperCase()}!',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Keep pushing your daily targets.',
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

        // TASK SUMMARY panel
        TerminalPanel(
          title: 'TASK SUMMARY',
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _summaryRow('PENDING:', '${pendingTasks.length}', SageColors.primary),
                const Divider(color: Colors.black12, height: 16),
                _summaryRow('OVERDUE:', '${overdueTasks.length}', SageColors.error),
                const Divider(color: Colors.black12, height: 16),
                const Text('UPCOMING TASKS:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: SageColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                if (upcomingTasks.isEmpty)
                  const SizedBox(height: 40)
                else
                  ...upcomingTasks.take(5).map((t) {
                    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
                    final d = t.deadline;
                    final dateStr = '${d.day} ${months[d.month - 1]}';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 6, color: SageColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(t.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                          ),
                          Text(dateStr, style: const TextStyle(fontSize: 10, color: SageColors.onSurfaceVariant)),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SageColors.onSurfaceVariant)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  Widget _buildTaskCalendarSubTab(List<Task> myTasks) {
    final now = DateTime.now();
    final firstDay = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final daysInMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 0).day;
    
    // Hardcoded list from Google Calendar ICS for Web
    final _googleHolidays = <String, String>{
      '2026-01-01': 'New Year\'s Day',
      '2026-01-26': 'Republic Day',
      '2026-03-24': 'Holi',
      '2026-04-10': 'Good Friday',
      '2026-08-15': 'Independence Day',
      '2026-10-02': 'Gandhi Jayanti',
      '2026-11-12': 'Diwali',
      '2026-12-25': 'Christmas Day',
    };

    List<Task> selectedTasks = [];
    if (_selectedCalendarDate != null) {
      selectedTasks = myTasks.where((t) => t.deadline.day == _selectedCalendarDate!.day && t.deadline.month == _selectedCalendarDate!.month && t.deadline.year == _selectedCalendarDate!.year && !t.isCompleted).toList();
    }

    return TerminalPanel(
      title: 'SESSIONS CALENDAR',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SageCalendar(
            currentMonth: _calendarMonth,
            onPreviousMonth: () => setState(() => _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month - 1, 1)),
            onNextMonth: () => setState(() => _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 1)),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.8,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            cellBuilder: (context, date) {
              final day = date.day;
              final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
              final holiday = _googleHolidays[dateStr];
              
              final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
              final isToday = day == now.day && date.month == now.month && date.year == now.year;
              final isSelected = _selectedCalendarDate?.day == day && _selectedCalendarDate?.month == date.month && _selectedCalendarDate?.year == date.year;
              
              final dayTasks = myTasks.where((t) => t.deadline.day == day && t.deadline.month == date.month && t.deadline.year == date.year && t.taskType == 'Session' && !t.isCompleted).toList();
              
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedCalendarDate = null;
                    } else {
                      _selectedCalendarDate = date;
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: isSelected ? 2.5 : 1.0),
                    color: isSelected ? const Color(0xFFFFF9C4) : (isToday ? SageColors.primaryContainer : (holiday != null ? SageColors.secondaryContainer : (isWeekend ? const Color(0xFFEEEEEE) : Colors.white))),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isSelected ? const [BoxShadow(color: Colors.black, offset: Offset(2, 2))] : null,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("$day", style: TextStyle(fontWeight: FontWeight.bold, color: holiday != null ? SageColors.secondary : Colors.black, fontSize: 12)),
                      if (holiday != null) Padding(padding: const EdgeInsets.symmetric(horizontal: 2.0), child: Text(holiday, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8, color: SageColors.secondary, fontWeight: FontWeight.bold, height: 1.1))),
                      const SizedBox(height: 2),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 2,
                        runSpacing: 2,
                        children: dayTasks.take(6).map((t) {
                          return Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle));
                        }).toList(),
                      ),
                    ],
                  ),
                  ),
                ),
              );
            },
          ),
          if (_selectedCalendarDate != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {}, // Consume taps
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5E1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 1.5),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
                ),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("TASKS FOR ${_selectedCalendarDate!.day}/${_selectedCalendarDate!.month}/${_selectedCalendarDate!.year}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  if (selectedTasks.isEmpty)
                    const Text("No tasks scheduled for this day.", style: TextStyle(color: SageColors.onSurfaceVariant))
                  else
                    ...selectedTasks.map((t) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.videocam, size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text(t.description, style: const TextStyle(fontSize: 10, color: SageColors.onSurfaceVariant)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
            ),
          ],
        ],
      ),
    );
  }

  // â”€â”€â”€ TAB 1: ACTIVITY â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  bool _showMyTasksOnly = true;

  Widget _buildActivityTab(BuildContext context, AppState state, Persona persona) {
    final now = DateTime.now();
    final allTasks = state.tasks;
    final taskDates = allTasks.map((t) => t.deadline).toList();

    final displayedTasks = allTasks.where((t) {
      final matchesPersona = _showMyTasksOnly ? (t.assignedTo == persona.id) : true;
      final matchesDate = _selectedDate == null ? true : t.deadline.day == _selectedDate!.day &&
          t.deadline.month == _selectedDate!.month &&
          t.deadline.year == _selectedDate!.year;
      return matchesPersona && matchesDate;
    }).toList();

    final todayStart = DateTime(now.year, now.month, now.day);
    final overdueTasks = allTasks.where((t) => t.assignedTo == persona.id && !t.isCompleted && t.deadline.isBefore(todayStart)).toList();
    final completedToday = displayedTasks.where((t) => t.isCompleted).length;
    final totalToday = displayedTasks.length;
    final double completionPercent = totalToday > 0 ? completedToday / totalToday : 0.0;

    // Monthly performance: sessions completed this month
    final myTasks = state.tasks.where((t) => t.assignedTo == persona.id).toList();
    final videosCompletedThisMonth = myTasks.where((t) =>
      t.isCompleted &&
      t.deadline.year == now.year &&
      t.deadline.month == now.month
    ).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Full Tasks Calendar
        Builder(
          builder: (ctx) {
            final _googleHolidays = <String, String>{
              '2026-01-01': 'New Year\'s Day',
              '2026-01-26': 'Republic Day',
              '2026-03-24': 'Holi',
              '2026-04-10': 'Good Friday',
              '2026-08-15': 'Independence Day',
              '2026-10-02': 'Gandhi Jayanti',
              '2026-11-12': 'Diwali',
              '2026-12-25': 'Christmas Day',
            };

            return SageCalendar(
              currentMonth: _calendarMonth,
              onPreviousMonth: () => setState(
                () => _calendarMonth = DateTime(
                  _calendarMonth.year,
                  _calendarMonth.month - 1,
                  1,
                ),
              ),
              onNextMonth: () => setState(
                () => _calendarMonth = DateTime(
                  _calendarMonth.year,
                  _calendarMonth.month + 1,
                  1,
                ),
              ),
              legend: Wrap(
                spacing: 12,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withOpacity(0.2),
                          border: Border.all(color: Colors.deepOrange),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "#",
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "Video",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.2),
                          border: Border.all(color: Colors.teal),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "#",
                          style: TextStyle(
                            color: Colors.teal,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "Design/Post",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.2),
                          border: Border.all(color: Colors.purple),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "#",
                          style: TextStyle(
                            color: Colors.purple,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "Active Client",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.2),
                          border: Border.all(color: Colors.indigo),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "#",
                          style: TextStyle(
                            color: Colors.indigo,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "Lead",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "#",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "Other",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              cellBuilder: (context, date) {
                final day = date.day;
                final dateStr =
                    "${date.year}-${date.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
                final holiday = _googleHolidays[dateStr];

                final isWeekend =
                    date.weekday == DateTime.saturday ||
                    date.weekday == DateTime.sunday;
                final isToday =
                    day == now.day &&
                    date.month == now.month &&
                    date.year == now.year;
                final isSelected = _selectedDate != null &&
                    _selectedDate!.day == day &&
                    _selectedDate!.month == date.month &&
                    _selectedDate!.year == date.year;

                final dayTasks = allTasks
                    .where(
                      (t) =>
                          t.assignedTo == persona.id &&
                          t.deadline.day == day &&
                          t.deadline.month == date.month &&
                          t.deadline.year == date.year,
                    )
                    .toList();

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedDate = null;
                      } else {
                        _selectedDate = date;
                      }
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: isSelected ? 2.5 : 1.0,
                      ),
                      color: isSelected
                          ? const Color(0xFFFFF9C4)
                          : (isToday
                                ? SageColors.primaryContainer
                                : (holiday != null
                                      ? SageColors.secondaryContainer
                                      : (isWeekend
                                            ? const Color(0xFFEEEEEE)
                                            : Colors.white))),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          "$day",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: holiday != null
                                ? SageColors.secondary
                                : Colors.black,
                            fontSize: 12,
                          ),
                        ),
                        if (holiday != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Text(
                              holiday,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 8,
                                color: SageColors.secondary,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                          ),
                        const SizedBox(height: 2),
                        Builder(
                      builder: (ctx) {
                        int videoCount = 0;
                        int postCount = 0;
                        int meetCount = 0;
                        int prodCount = 0;
                        int miscCount = 0;
                        int otherCount = 0;

                        for (var t in dayTasks) {
                          final typeStr = (t.taskType ?? '').toLowerCase();
                          
                          if (typeStr.contains('video')) {
                            videoCount++;
                          } else if (typeStr.contains('post') || typeStr.contains('photo') || typeStr.contains('upload')) {
                            postCount++;
                          } else if (typeStr.contains('session') || typeStr.contains('meeting')) {
                            meetCount++;
                          } else if (typeStr.contains('product')) {
                            prodCount++;
                          } else if (typeStr.contains('misc')) {
                            miscCount++;
                          } else {
                            otherCount++;
                          }
                        }

                        return Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 2,
                          runSpacing: 2,
                          children: [
                            if (videoCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  border: Border.all(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(videoCount.toString(), style: const TextStyle(color: Colors.blue, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            if (postCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  border: Border.all(color: Colors.orange),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(postCount.toString(), style: const TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            if (meetCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.2),
                                  border: Border.all(color: Colors.purple),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(meetCount.toString(), style: const TextStyle(color: Colors.purple, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            if (prodCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.brown.withOpacity(0.2),
                                  border: Border.all(color: Colors.brown),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(prodCount.toString(), style: const TextStyle(color: Colors.brown, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            if (miscCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(miscCount.toString(), style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            if (otherCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.withOpacity(0.2),
                                  border: Border.all(color: Colors.blueGrey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(otherCount.toString(), style: const TextStyle(color: Colors.blueGrey, fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        );
                      },
                    ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 14),

        // Tasks Completed Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black, width: 1.5),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: SageColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '$completedToday/$totalToday',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: SageColors.primary),
                          ),
                        ],
                      ),
                      const Text(
                        'TASKS COMPLETED TODAY',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: SageColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _showMyTasksOnly = !_showMyTasksOnly),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: SageColors.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 1.2),
                      ),
                      child: Text(
                        _showMyTasksOnly ? 'MY TASKS' : 'TEAM TASKS',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: SageColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: completionPercent.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: SageColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Monthly Performance
        TerminalPanel(
          title: 'MONTHLY PERFORMANCE',
          child: StatChip(
            label: 'VIDEOS COMPLETED THIS MONTH',
            value: '$videosCompletedThisMonth',
            valueColor: SageColors.tertiary,
            icon: Icons.calendar_month,
          ),
        ),
        const SizedBox(height: 14),

        // Task list for selected date
        if (displayedTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: const Center(
              child: Text(
                'NO TASKS ASSIGNED ON THIS DATE',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: SageColors.onSurfaceVariant),
              ),
            ),
          )
        else
          Column(
            children: displayedTasks.map((t) {
              final isOverdue = !t.isCompleted && t.deadline.isBefore(DateTime.now());
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0),
                  ],
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: t.isSubmitted,
                      onChanged: (val) {
                        if (val == true) {
                          context.read<AppState>().submitTask(t.id);
                        } else {
                          context.read<AppState>().unsubmitTask(t.id);
                        }
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                decoration: t.isCompleted ? TextDecoration.lineThrough : null,
                                color: t.isCompleted ? SageColors.onSurfaceVariant : Colors.black,
                              ),
                            ),
                            if (t.description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(t.description, style: const TextStyle(fontSize: 10, color: SageColors.onSurfaceVariant)),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: isOverdue
                          ? const StatusBadge(label: 'OVERDUE', color: SageColors.error)
                          : (t.isCompleted ? const StatusBadge(label: 'DONE', color: SageColors.primary) : const SizedBox()),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        if (overdueTasks.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text('OVERDUE TASKS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: SageColors.error)),
          const SizedBox(height: 12),
          Column(
            children: overdueTasks.map((t) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: SageColors.error, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: SageColors.error, offset: Offset(2, 2), blurRadius: 0),
                  ],
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: t.isSubmitted,
                      onChanged: (val) {
                        if (val == true) {
                          context.read<AppState>().submitTask(t.id);
                        } else {
                          context.read<AppState>().unsubmitTask(t.id);
                        }
                      },
                      activeColor: SageColors.error,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.title,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            if (t.description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(t.description, style: const TextStyle(fontSize: 10, color: SageColors.onSurfaceVariant)),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: StatusBadge(label: 'OVERDUE', color: SageColors.error),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // ————————————————————————————————————————————————————————————————————————————
  Widget _buildProfileTab(BuildContext context, AppState state, Persona persona) {
    final emp = state.employees.firstWhereOrNull((e) => e.id == persona.id);
    if (emp == null) return const Center(child: Text('Employee not found'));

    final hasVideographer = false;
    final hasVideoEditor = emp.role.toLowerCase().contains('video editor') || emp.role.toLowerCase().contains('video');
    final isSalaried = emp.monthlySalary > 0;

    final monthNames = const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final paidTillStr = emp.paidMonths.isEmpty ? 'None' : monthNames.lastWhere((m) => emp.paidMonths.contains(m), orElse: () => emp.paidMonths.last);
    final now = DateTime.now();
    
    int pendingMonths = 0;
    if (emp.paidMonths.isNotEmpty) {
      int lastPaidMonth = monthNames.indexOf(paidTillStr) + 1;
      int lastPaidYear = now.year;
      if (now.month < lastPaidMonth) lastPaidYear = now.year - 1;
      int monthsSinceLastPaid = (now.year - lastPaidYear) * 12 + (now.month - lastPaidMonth);
      int offset = (emp.paymentMode == 'Late' || emp.name.toLowerCase().contains('debjit') || emp.name.toLowerCase().contains('video editor')) ? 1 : 0;
      pendingMonths = (monthsSinceLastPaid - offset).clamp(0, 99);
    } else {
      final monthsSinceJoin = (now.year - emp.joiningDate.year) * 12 + (now.month - emp.joiningDate.month);
      bool isLate = emp.paymentMode == 'Late' || emp.name.toLowerCase().contains('debjit') || emp.name.toLowerCase().contains('video editor');
      final totalPayable = monthsSinceJoin + (isLate ? 0 : 1);
      pendingMonths = totalPayable.clamp(0, 99);
    }

    // Videographer Payout logic
    final unpaidSessionsList = state.tasks.where((t) => t.assignedTo == emp.id && t.taskType == 'Session' && t.isCompleted && !t.isPaidToVideographer).toList();
    double pendingSessionPayout = 0;
    for (var t in unpaidSessionsList) {
      final c = state.clients.firstWhereOrNull((client) => client.id == t.clientId);
      if (c != null) pendingSessionPayout += c.sessionRate;
    }

    // Video Editor Payout logic
    final unpaidVideosList = state.tasks.where((t) => t.assignedTo == emp.id && t.taskType != 'Session' && t.isCompleted && !t.isPaidToVideographer).toList();
    double pendingVideoPayout = emp.perVideoRate * unpaidVideosList.length;

    final pm = emp.pendingPayMonth ?? '';
    final bool sessionPaymentCleared = emp.paymentCleared && pm.contains('Sessions');
    final bool videoPaymentCleared = emp.paymentCleared && pm.contains('Videos');
    final bool salaryPaymentCleared = emp.paymentCleared && !pm.contains('Sessions') && !pm.contains('Videos');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        TerminalPanel(
          title: 'ACCOUNT DATA',
          child: Column(
            children: [
              Center(
                child: ClipOval(
                  child: Transform.scale(scale: 1.7, child: Image.asset(availableAvatars[emp.avatar % availableAvatars.length], fit: BoxFit.cover, width: 100, height: 100)),
                ),
              ),
              const SizedBox(height: 16),
              _profileRow('NAME', emp.name),
              _profileRow('ROLE', emp.role.toUpperCase()),
              _profileRow('ID CODE', persona.id),
              _profileRow('ADDRESS', emp.address.isNotEmpty ? emp.address : '---'),
              _profileRow('PHONE', emp.phone.isNotEmpty ? emp.phone : '---'),
              _profileRow('EMAIL', emp.email.isNotEmpty ? emp.email : '---'),
              const SizedBox(height: 8),
            ],
          ),
        ),

        if (isSalaried) ...[
          const SizedBox(height: 16),
          TerminalPanel(
            title: 'SALARY DATA',
            child: Column(
              children: [
                _profileRow('MONTHLY SALARY', '\u20B9${emp.monthlySalary.toStringAsFixed(0)}'),
                _profileRow('PENDING MONTHS', '$pendingMonths'),
                _profileRow('PAID TILL', paidTillStr),
                if (salaryPaymentCleared) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AppState>().toggleEmployeePaymentApproved(emp.id, true);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Salary Receipt Confirmed!')));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: SageColors.primary, foregroundColor: Colors.white),
                      child: const Text('RECEIVE SALARY'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],

        if (hasVideographer) ...[
          const SizedBox(height: 16),
          TerminalPanel(
            title: 'VIDEOGRAPHER FINANCE',
            child: Column(
              children: [
                _profileRow('UNPAID SESSIONS', '${unpaidSessionsList.length}'),
                _profileRow('PENDING PAY', sessionPaymentCleared ? '\u20B9${emp.pendingPayAmount.toStringAsFixed(0)}' : '\u20B9${pendingSessionPayout.toStringAsFixed(0)}'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: sessionPaymentCleared
                        ? () {
                            context.read<AppState>().toggleEmployeePaymentApproved(emp.id, true);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session Payment Receipt Confirmed!')));
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sessionPaymentCleared ? SageColors.primary : Colors.grey.shade300,
                      foregroundColor: sessionPaymentCleared ? Colors.white : Colors.grey.shade600,
                    ),
                    child: Text(sessionPaymentCleared ? 'RECEIVE PAYMENT (SESSIONS)' : 'WAITING FOR SESSIONS PAYMENT'),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (hasVideoEditor && !isSalaried) ...[
          const SizedBox(height: 16),
          TerminalPanel(
            title: 'VIDEO EDITOR FINANCE',
            child: Column(
              children: [
                _profileRow('PER VIDEO RATE', '\u20B9${emp.perVideoRate.toStringAsFixed(0)}'),
                _profileRow('UNPAID VIDEOS', '${unpaidVideosList.length}'),
                _profileRow('PENDING PAY', videoPaymentCleared ? '\u20B9${emp.pendingPayAmount.toStringAsFixed(0)}' : '\u20B9${pendingVideoPayout.toStringAsFixed(0)}'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: videoPaymentCleared
                        ? () {
                            context.read<AppState>().toggleEmployeePaymentApproved(emp.id, true);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video Payment Receipt Confirmed!')));
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: videoPaymentCleared ? SageColors.primary : Colors.grey.shade300,
                      foregroundColor: videoPaymentCleared ? Colors.white : Colors.grey.shade600,
                    ),
                    child: Text(videoPaymentCleared ? 'RECEIVE PAYMENT (VIDEOS)' : 'WAITING FOR VIDEOS PAYMENT'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
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

  // â”€â”€â”€ EDIT PERSONAL DETAILS DIALOG â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
              title: const Text('EDIT PERSONAL DETAILS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SageTextField(controller: nameCtrl, label: 'Name'),
                    const SizedBox(height: 10),
                    SageTextField(controller: addressCtrl, label: 'Address'),
                    const SizedBox(height: 10),
                    SageTextField(controller: phoneCtrl, label: 'Phone'),
                    const SizedBox(height: 10),
                    SageTextField(controller: emailCtrl, label: 'Email'),
                    const SizedBox(height: 10),
                    SageTextField(controller: prefNameCtrl, label: 'Preferred Name'),
                    const SizedBox(height: 10),
                    SageTextField(controller: emergencyCtrl, label: 'Emergency Contact'),
                    const SizedBox(height: 10),
                    SageTextField(controller: bioCtrl, label: 'Professional Bio', maxLines: 3),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedWorkLocation,
                      decoration: const InputDecoration(labelText: 'Work Location'),
                      items: ['Office', 'Remote', 'Hybrid'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => selectedWorkLocation = v ?? 'Office'),
                      dropdownColor: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedWorkStyle,
                      decoration: const InputDecoration(labelText: 'Work Style Preference'),
                      items: ['Independent thinker', 'Team collaborator', 'Detail-oriented', 'Fast executor', 'Strategic planner']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => selectedWorkStyle = v ?? 'Independent thinker'),
                      dropdownColor: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    SageTextField(controller: interestsCtrl, label: 'Interests / Hobbies'),
                    const SizedBox(height: 10),
                    const Text('KEY SKILLS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: ['Editing', 'Sales', 'Design', 'Marketing', 'Coding'].map((skill) {
                        final isSelected = selectedSkills.contains(skill);
                        return FilterChip(
                          label: Text(skill, style: const TextStyle(fontSize: 10)),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) selectedSkills.add(skill);
                              else selectedSkills.remove(skill);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    const Text('STRENGTHS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: ['Leadership', 'Problem Solving', 'Creativity', 'Communication'].map((strength) {
                        final isSelected = selectedStrengths.contains(strength);
                        return FilterChip(
                          label: Text(strength, style: const TextStyle(fontSize: 10)),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) selectedStrengths.add(strength);
                              else selectedStrengths.remove(strength);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text('CHOOSE AVATAR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: List.generate(availableAvatars.length, (index) {
                        final isSelected = selectedAvatar == index;
                        return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => selectedAvatar = index),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? SageColors.primary : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: CircleAvatar(
                              backgroundImage: AssetImage(availableAvatars[index]),
                              radius: 20,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: SageColors.primary),
                  onPressed: () {
                    context.read<AppState>().updateEmployeePersonal(
                      emp.id,
                      name: nameCtrl.text,
                      address: addressCtrl.text,
                      phone: phoneCtrl.text,
                      email: emailCtrl.text,
                      preferredName: prefNameCtrl.text,
                      emergencyContact: emergencyCtrl.text,
                      professionalBio: bioCtrl.text,
                      workLocation: selectedWorkLocation,
                      workStylePreference: selectedWorkStyle,
                      interests: interestsCtrl.text,
                      keySkills: selectedSkills,
                      strengths: selectedStrengths,
                      avatar: selectedAvatar,
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('SAVE'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

