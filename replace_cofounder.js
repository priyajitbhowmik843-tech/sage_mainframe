const fs=require('fs');
const p='C:/Users/Priyajit Bhowmik/Downloads/n sage os/sage os/sage os/sage_mainframe/lib/screens/cofounder_dashboard.dart';
const t=fs.readFileSync(p,'utf8');
const lines=t.split('\n');
const prefix=lines.slice(0, 1830).join('\n');
const suffix=lines.slice(1922).join('\n');
const replacement = `        SageCalendar(
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
            final dateStr = "\${date.year}-\${date.month.toString().padLeft(2, '0')}-\${day.toString().padLeft(2, '0')}";
            final holiday = _googleHolidays[dateStr];
            
            final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
            final isToday = day == now.day && date.month == now.month && date.year == now.year;
            final isSelected = _selectedCalendarDate?.day == day && _selectedCalendarDate?.month == date.month && _selectedCalendarDate?.year == date.year;
            
            final dayTasks = allTasks.where((t) => t.deadline.day == day && t.deadline.month == date.month && t.deadline.year == date.year && !t.isCompleted).toList();
            
            return GestureDetector(
              onTap: () => setState(() => _selectedCalendarDate = date),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: isSelected ? 2.5 : 1.0),
                  color: isSelected ? const Color(0xFFFFF9C4) : (isToday ? SageColors.primaryContainer : (holiday != null ? SageColors.secondaryContainer : (isWeekend ? const Color(0xFFEEEEEE) : Colors.white))),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected ? const [BoxShadow(color: Colors.black, offset: Offset(2, 2))] : null,
                ),
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
                        Color dotColor = Colors.blue;
                        final title = t.title.toLowerCase();
                        if (title.contains('video')) dotColor = Colors.green;
                        else if (title.contains('post') || title.contains('design')) dotColor = Colors.pink;
                        else if (title.contains('lead') || title.contains('marketing')) dotColor = Colors.purple;
                        
                        return Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle));
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),`;
fs.writeFileSync(p, prefix + '\n' + replacement + '\n' + suffix);
console.log('updated cofounder_dashboard.dart');
