import 'dart:io';
import 'dart:convert';

void main() async {
  var request = await HttpClient().getUrl(Uri.parse('https://calendar.google.com/calendar/ical/en.indian%23holiday%40group.v.calendar.google.com/public/basic.ics'));
  var response = await request.close();
  var lines = await response.transform(utf8.decoder).transform(LineSplitter()).toList();
  
  Map<String, String> holidays = {};
  String? currentSummary;
  String? currentDate;
  
  for (var line in lines) {
    if (line.startsWith('SUMMARY:')) {
      currentSummary = line.substring(8);
    } else if (line.startsWith('DTSTART;VALUE=DATE:')) {
      final dt = line.substring(19);
      if (dt.length == 8) {
        final yearStr = dt.substring(0, 4);
        final month = dt.substring(4, 6);
        final day = dt.substring(6, 8);
        final year = int.tryParse(yearStr) ?? 0;
        if (year >= 2025 && year <= 2028) {
          currentDate = "$yearStr-$month-$day";
        }
      }
    } else if (line == 'END:VEVENT') {
      if (currentDate != null && currentSummary != null) {
        holidays[currentDate] = currentSummary;
      }
      currentDate = null;
      currentSummary = null;
    }
  }
  
  var sortedKeys = holidays.keys.toList()..sort();
  print('Map<String, String> googleHolidays = {');
  for (var k in sortedKeys) {
    String safeSummary = holidays[k]!.replaceAll("'", "\\'");
    print("  '$k': '$safeSummary',");
  }
  print('};');
}
