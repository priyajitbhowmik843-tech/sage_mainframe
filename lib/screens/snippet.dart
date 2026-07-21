import 'package:sage_mainframe/widgets/sage_expansion_tile.dart';
        ...AppState.personas.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          final color = _getRoleColor(p.roleLabel);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: color,
              image: const DecorationImage(
                image: AssetImage('assets/logo/2l.png'),
                fit: BoxFit.scaleDown,
                opacity: 0.35,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 1.5),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0)],
            ),
            child: SageExpansionTile(
              controller: _personaExpControllers.putIfAbsent(i, () => ExpansionTileController()),
              onExpansionChanged: (expanded) {
                if (expanded) {
                  _personaExpControllers.forEach((key, controller) {
                    if (key != i && controller.isExpanded) controller.collapse();
                  });
                }
              },
              shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.transparent)),
              collapsedShape: const RoundedRectangleBorder(side: BorderSide(color: Colors.transparent)),
              title: Row(
                children: [
                  Container(
                    width: 72, height: 72,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: ClipOval(child: Image.asset(availableAvatars[p.avatar % availableAvatars.length], fit: BoxFit.cover, width: 72, height: 72)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((p.preferredName.isNotEmpty ? p.preferredName : p.name).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                        Text(p.roleLabel, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("\u{1F4DE} ${p.phone.isNotEmpty ? p.phone : 'Not Provided'}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      Text("\u{2709} ${p.email.isNotEmpty ? p.email : 'Not Provided'}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      Text("\u{1F4CD} ${p.address.isNotEmpty ? p.address : 'Not Provided'}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      const SizedBox(height: 8),
                      Text("ðŸ“„ Bio: ${p.professionalBio.isNotEmpty ? p.professionalBio : 'Not Provided'}", style: const TextStyle(fontSize: 12, color: Colors.black87, fontStyle: FontStyle.italic)),
                      if (p.keySkills.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text("ðŸ› ï¸ Skills: ${p.keySkills.join(', ')}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.black, width: 1.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("System Core Persona", style: TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(8)),
                        child: const Text("ACCESS: FULL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }),

        ...state.employees.asMap().entries.map((entry) {
          final i = entry.key + AppState.personas.length;
          final employee = entry.value;
          final color = _getRoleColor(employee.role);
          final isVideo = (employee.hasRole('videographer') || employee.hasRole('videographer/cinematographer')) && (employee.videoEditorPayType != 'Salary' && employee.monthlySalary == 0);
          final isVideoEditorPerVideo = employee.hasRole('video editor') && (employee.videoEditorPayType == 'Per Video Rate' && employee.monthlySalary == 0);
          final isVideoEditor = employee.hasRole('video editor');
          final isME = employee.hasRole('marketing executive') || employee.hasRole('marketing') || employee.hasRole('page management executive');
          
                    double pendingVideoPayout = 0;
          int unpaidVideosCount = 0;
          double pendingSessionPayout = 0;
          int unpaidSessionsCount = 0;

          if (isVideo) {
            final unpaidSessions = state.tasks.where((t) => t.assignedTo == employee.id && (t.taskType == 'Session' || t.taskType == 'Miscellaneous Session') && t.isCompleted && !t.isPaidToVideographer).toList();
            unpaidSessionsCount = unpaidSessions.length;
            for (final t in unpaidSessions) {
              if (t.manualPaymentAmount != null && t.manualPaymentAmount! > 0) {
                pendingSessionPayout += t.manualPaymentAmount!;
              } else {
                final c = state.clients.where((c) => c.id == t.clientId).firstOrNull;
                if (c != null) pendingSessionPayout += c.sessionRate;
              }
            }
          }
          if (isVideoEditorPerVideo) {
            final unpaidVideos = state.tasks.where((t) => t.assignedTo == employee.id && t.taskType != 'Session' && t.isCompleted && !t.isPaidToVideographer).toList();
            unpaidVideosCount = unpaidVideos.length;
            pendingVideoPayout = unpaidVideosCount * employee.perVideoRate;
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: color,
              image: const DecorationImage(
                image: AssetImage('assets/logo/1l.png'),
                fit: BoxFit.scaleDown,
                opacity: 0.15,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 1.5),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0)],
            ),
            child: SageExpansionTile(
              controller: _empExpControllers.putIfAbsent(employee.id, () => ExpansionTileController()),
              onExpansionChanged: (expanded) {
                if (expanded) {
                  _empExpControllers.forEach((key, controller) {
                    if (key != employee.id && controller.isExpanded) controller.collapse();
                  });
                }
              },
              shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.transparent)),
              collapsedShape: const RoundedRectangleBorder(side: BorderSide(color: Colors.transparent)),
              title: Row(
                children: [
                  Container(
                    width: 72, height: 72,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: ClipOval(child: Image.asset(availableAvatars[employee.avatar % availableAvatars.length], fit: BoxFit.cover, width: 72, height: 72)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(employee.preferredName.isNotEmpty ? employee.preferredName : employee.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                        Text("${employee.role}", style: const TextStyle(fontSize: 10, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ðŸ“ž ${employee.phone.isNotEmpty ? employee.phone : 'Not Provided'}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      Text("âœ‰ï¸ ${employee.email.isNotEmpty ? employee.email : 'Not Provided'}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      Text("ðŸ“ ${employee.address.isNotEmpty ? employee.address : 'Not Provided'}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      if (employee.preferredName.isNotEmpty) Text("ðŸ‘¤ Preferred Name: ${employee.preferredName}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      if (employee.workLocation.isNotEmpty) Text("ðŸ¢ Work Location: ${employee.workLocation}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      if (employee.emergencyContact.isNotEmpty) Text("ðŸš¨ Emergency Contact: ${employee.emergencyContact}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      if (employee.professionalBio.isNotEmpty) Text("ðŸ“„ Bio: ${employee.professionalBio}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      if (employee.keySkills.isNotEmpty) Text("ðŸ› ï¸ Skills: ${employee.keySkills.join(', ')}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      if (employee.strengths.isNotEmpty) Text("ðŸ’ª Strengths: ${employee.strengths.join(', ')}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      if (employee.workStylePreference.isNotEmpty) Text("ðŸŽ¯ Work Style: ${employee.workStylePreference}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      if (employee.interests.isNotEmpty) Text("ðŸ”¥ Interests: ${employee.interests}", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.black, width: 1.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isVideo) ...[
                        Text("PENDING SESSION PAYOUT: \u20B9${pendingSessionPayout.toStringAsFixed(0)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                        Text("UNPAID SESSIONS: $unpaidSessionsCount", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 8),
                      ],
                      if (isVideoEditorPerVideo) ...[
                        Text("PENDING VIDEO PAYOUT: \u20B9${pendingVideoPayout.toStringAsFixed(0)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                        Text("UNPAID VIDEOS: $unpaidVideosCount", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 8),
                      ],
                      if (!isVideo && !isVideoEditorPerVideo) ...[
                        if (isME) ...[
                          const Text("COMMISSION BASED", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                          Text("Paid Till: ${employee.paidMonths.isEmpty ? 'None' : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'].lastWhere((m) => employee.paidMonths.contains(m), orElse: () => employee.paidMonths.last)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ] else ...[
                          Text("SALARY: \u20B9${employee.monthlySalary.toStringAsFixed(0)} / mo", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                          Text("Paid Till: ${employee.paidMonths.isEmpty ? 'None' : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'].lastWhere((m) => employee.paidMonths.contains(m), orElse: () => employee.paidMonths.last)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ],
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (isVideo)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                                    onPressed: () {
                                      _showPaySessionsDialog(context, state, employee, unpaidSessionsCount, true);
                                    },
                                    child: const Text("PAY SESSIONS", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              if (isVideoEditorPerVideo)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                                    onPressed: () {
                                      _showPaySessionsDialog(context, state, employee, unpaidVideosCount, false);
                                    },
                                    child: const Text("PAY VIDEOS", style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              if (!isVideo && !isVideoEditorPerVideo)
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                                  onPressed: () {
                                    _showPayEmployeeDialog(context, state, employee);
                                  },
                                  child: Text(
                                    isME ? "CLEAR PAYMENT" : "PAY SALARY",
                                    style: const TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.black),
                                onPressed: () => _showEditEmployeeDialog(context, employee),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: SageColors.error),
                                onPressed: () async {
                                  final ok = await showConfirmDialog(context, "TERMINATE EMPLOYEE", "Are you sure you want to terminate ${employee.name}?");
                                  if (ok && context.mounted) {
                                    context.read<AppState>().terminateEmployee(employee.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }),
      ],
    );
  }

  String _taskSubTab = 'CALENDAR'; // 'CALENDAR', 'TEAM'
  String? _selectedPersonnelId;
  
  String _newTaskType = 'Daily Video';
  List<String> _newTaskAssigneeIds = [];
  String? _dailyVideoAssigneeId;
  List<String> _newTaskClients = [];
  final TextEditingController _newTaskTitleCtrl = TextEditingController();
  final TextEditingController _newTaskDescCtrl = TextEditingController();
  TimeOfDay _newTaskTime = const TimeOfDay(hour: 17, minute: 0);
  bool _isAddTaskExpanded = false;
  // Session booking state
  String? _sessionVideographerId;
  List<String> _sessionClientIds = [];
  
  DateTime _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedCalendarDate;

  final Map<String, String> _holidays = {
    '01-01': 'New Year\'s Day',
    '26-01': 'Republic Day',
    '14-02': 'Valentine\'s Day',
    '08-03': 'Maha Shivaratri',
    '25-03': 'Holi',
    '29-03': 'Good Friday',
    '09-04': 'Ugadi / Gudi Padwa',
    '11-04': 'Eid al-Fitr',
    '17-04': 'Rama Navami',
    '01-05': 'Labour Day',
    '17-06': 'Eid al-Adha',
    '17-07': 'Muharram',
    '15-08': 'Independence Day',
    '26-08': 'Janmashtami',
    '07-09': 'Ganesh Chaturthi',
    '02-10': 'Gandhi Jayanti',
    '11-10': 'Dussehra',
    '31-10': 'Diwali',
    '25-12': 'Christmas',
  };

  Map<String, String> _googleHolidays = {};
  bool _isLoadingHolidays = false;

  @override
  void initState() {
    super.initState();
    _fetchGoogleHolidays();
  }

  Future<void> _fetchGoogleHolidays() async {
    setState(() => _isLoadingHolidays = true);
    // Hardcoded list from Google Calendar ICS to completely bypass CORS on Web and prevent missing holidays
    setState(() {
      _googleHolidays = {
  '2025-01-01': 'New Year\'s Day',
  '2025-01-06': 'Guru Govind Singh Jayanti',
  '2025-01-14': 'Pongal',
  '2025-01-26': 'Republic Day',
  '2025-02-02': 'Vasant Panchami',
  '2025-02-12': 'Guru Ravidas Jayanti',
  '2025-02-19': 'Shivaji Jayanti',
  '2025-02-23': 'Maharishi Dayanand Saraswati Jayanti',
  '2025-02-26': 'Maha Shivaratri',
  '2025-03-02': 'Ramadan Start',
  '2025-03-13': 'Holika Dahana',
  '2025-03-14': 'Dolyatra',
  '2025-03-28': 'Jamat Ul-Vida',
  '2025-03-30': 'Ugadi',
  '2025-03-31': 'Ramzan Id',
  '2025-04-06': 'Rama Navami',
  '2025-04-10': 'Mahavir Jayanti',
  '2025-04-13': 'Vaisakhi',
  '2025-04-14': 'Mesadi',
  '2025-04-15': 'Bahag Bihu',
  '2025-04-18': 'Good Friday',
  '2025-04-20': 'Easter Day',
  '2025-05-09': 'Birthday of Rabindranath',
  '2025-05-12': 'Buddha Purnima',
  '2025-06-07': 'Bakrid',
  '2025-06-27': 'Rath Yatra',
  '2025-07-06': 'Muharram/Ashura',
  '2025-08-09': 'Raksha Bandhan',
  '2025-08-15': 'Parsi New Year',
  '2025-08-16': 'Janmashtami',
  '2025-08-27': 'Ganesh Chaturthi',
  '2025-09-05': 'Milad un-Nabi',
  '2025-09-22': 'First Day of Sharad Navratri',
  '2025-09-28': 'First Day of Durga Puja Festivities',
  '2025-09-29': 'Maha Saptami',
  '2025-09-30': 'Maha Ashtami',
  '2025-10-01': 'Maha Navami',
  '2025-10-02': 'Mahatma Gandhi Jayanti',
  '2025-10-07': 'Maharishi Valmiki Jayanti',
  '2025-10-10': 'Karaka Chaturthi',
  '2025-10-20': 'Naraka Chaturdasi',
  '2025-10-22': 'Govardhan Puja',
  '2025-10-23': 'Bhai Duj',
  '2025-10-28': 'Chhat Puja (Pratihar Sashthi/Surya Sashthi)',
  '2025-11-05': 'Guru Nanak Jayanti',
  '2025-11-24': 'Guru Tegh Bahadur\'s Martyrdom Day',
  '2025-12-24': 'Christmas Eve',
  '2025-12-25': 'Christmas',
  '2026-01-01': 'New Year\'s Day',
  '2026-01-03': 'Hazarat Ali\'s Birthday',
  '2026-01-14': 'Makar Sankranti',
  '2026-01-23': 'Vasant Panchami',
  '2026-01-26': 'Republic Day',
  '2026-02-01': 'Guru Ravidas Jayanti',
  '2026-02-12': 'Maharishi Dayanand Saraswati Jayanti',
  '2026-02-15': 'Maha Shivaratri',
  '2026-02-19': 'Ramadan Start',
  '2026-03-03': 'Holika Dahana',
  '2026-03-04': 'Holi',
  '2026-03-19': 'Ugadi',
  '2026-03-20': 'Jamat Ul-Vida',
  '2026-03-21': 'Ramzan Id',
  '2026-03-26': 'Rama Navami',
  '2026-03-31': 'Mahavir Jayanti',
  '2026-04-03': 'Good Friday',
  '2026-04-05': 'Easter Day',
  '2026-04-14': 'Ambedkar Jayanti',
  '2026-04-15': 'Bahag Bihu',
  '2026-05-01': 'Buddha Purnima',
  '2026-05-09': 'Birthday of Rabindranath',
  '2026-05-28': 'Bakrid',
  '2026-06-26': 'Muharram/Ashura (tentative)',
  '2026-07-16': 'Rath Yatra',
  '2026-08-15': 'Independence Day',
  '2026-08-26': 'Milad un-Nabi (tentative)',
  '2026-08-28': 'Raksha Bandhan',
  '2026-09-04': 'Janmashtami (Smarta)',
  '2026-09-14': 'Ganesh Chaturthi',
  '2026-10-02': 'Mahatma Gandhi Jayanti',
  '2026-10-11': 'First Day of Sharad Navratri',
  '2026-10-17': 'First Day of Durga Puja Festivities',
  '2026-10-18': 'Maha Saptami',
  '2026-10-19': 'Maha Ashtami',
  '2026-10-20': 'Dussehra',
  '2026-10-26': 'Maharishi Valmiki Jayanti',
  '2026-10-29': 'Karaka Chaturthi',
  '2026-11-08': 'Naraka Chaturdasi',
  '2026-11-09': 'Govardhan Puja',
  '2026-11-11': 'Bhai Duj',
  '2026-11-15': 'Chhat Puja (Pratihar Sashthi/Surya Sashthi)',
  '2026-11-24': 'Guru Nanak Jayanti',
  '2026-12-23': 'Hazarat Ali\'s Birthday',
  '2026-12-24': 'Christmas Eve',
  '2026-12-25': 'Christmas',
  '2027-01-01': 'New Year\'s Day',
  '2027-01-15': 'Makar Sankranti',
  '2027-01-26': 'Republic Day',
  '2027-02-09': 'Ramadan Start (tentative)',
  '2027-02-11': 'Vasant Panchami',
  '2027-02-19': 'Shivaji Jayanti',
  '2027-03-06': 'Maha Shivaratri',
  '2027-03-10': 'Ramzan Id (tentative)',
  '2027-03-22': 'Holi',
  '2027-03-26': 'Good Friday',
  '2027-03-28': 'Easter Day',
  '2027-04-07': 'Gudi Padwa',
  '2027-04-14': 'Ambedkar Jayanti',
  '2027-04-15': 'Rama Navami',
  '2027-05-17': 'Bakrid (tentative)',
  '2027-06-16': 'Muharram/Ashura (tentative)',
  '2027-07-05': 'Rath Yatra',
  '2027-08-15': 'Independence Day',
  '2027-08-17': 'Raksha Bandhan',
  '2027-08-25': 'Janmashtami',
  '2027-09-04': 'Ganesh Chaturthi',
  '2027-09-12': 'Onam',
  '2027-09-30': 'First Day of Sharad Navratri',
  '2027-10-02': 'Mahatma Gandhi Jayanti',
  '2027-10-05': 'First Day of Durga Puja Festivities',
  '2027-10-09': 'Dussehra',
  '2027-10-18': 'Karaka Chaturthi',
  '2027-10-29': 'Diwali/Deepavali',
  '2027-10-31': 'Bhai Duj',
  '2027-11-04': 'Chhat Puja (Pratihar Sashthi/Surya Sashthi)',
  '2027-11-24': 'Guru Tegh Bahadur\'s Martyrdom Day',
  '2027-12-12': 'Hazarat Ali\'s Birthday',
  '2027-12-24': 'Christmas Eve',
  '2027-12-25': 'Christmas',
      };
    });
    if (mounted) setState(() => _isLoadingHolidays = false);
  }

  Widget _buildTaskSubTabBtn(String title, {int badgeCount = 0}) {
    final isSelected = _taskSubTab == title;
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );

    return GestureDetector(
      onTap: () => setState(() => _taskSubTab = title),
      child: badgeCount > 0
          ? Badge(
              label: Text(badgeCount.toString()),
              child: child,
            )
          : child,
    );
  }
