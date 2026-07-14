const fs=require('fs');
const p='C:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/lib/screens/videographer_dashboard.dart';
let t=fs.readFileSync(p,'utf8');
const orig=fs.readFileSync('C:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/temp_cal_video.txt','utf8');

const replacement = `Widget _buildCalendar(AppState state, Persona persona) {
    final now = DateTime.now();
    final mySessionTasks = state.tasks.where((t) => t.assignedTo == persona.id && t.taskType == 'Session').toList();

    return SageCalendar(
      currentMonth: _calendarMonth,
      onPreviousMonth: () => setState(() => _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month - 1, 1)),
      onNextMonth: () => setState(() => _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 1)),
      legend: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          calendarLegend(SageColors.primary, 'Completed'),
          const SizedBox(width: 14),
          calendarLegend(SageColors.tertiary, 'Booked'),
          const SizedBox(width: 14),
          calendarLegend(SageColors.error, 'Pending'),
        ],
      ),
      cellBuilder: (ctx, date) {
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
                Text('\${date.day}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
              ],
            ),
          ),
        );
      },
    );
  }

  `;

t = t.replace(orig, replacement);

const legendStart = t.indexOf('Widget _legend(Color c, String label)');
if (legendStart !== -1) {
  const legendEnd = t.indexOf(']);', legendStart) + 3;
  t = t.substring(0, legendStart) + t.substring(legendEnd);
}

fs.writeFileSync(p, t);
console.log('Video dashboard updated');
