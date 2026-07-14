import 'dart:io';
import 'dart:convert';

void main() async {
  var request = await HttpClient().getUrl(Uri.parse('https://calendar.google.com/calendar/ical/en.indian%23holiday%40group.v.calendar.google.com/public/basic.ics'));
  var response = await request.close();
  var lines = await response.transform(utf8.decoder).transform(LineSplitter()).toList();
  var fetched = <String, String>{};
  String? currentSummary;
  String? currentDate;
  
  for(var line in lines) {
    if (line.startsWith('SUMMARY:')) {
      currentSummary = line.substring(8);
    } else if (line.startsWith('DTSTART;VALUE=DATE:')) {
      var dt = line.substring(19);
      if (dt.length == 8) {
        var yearStr = dt.substring(0, 4);
        var month = dt.substring(4, 6);
        var day = dt.substring(6, 8);
        var year = int.tryParse(yearStr) ?? 0;
        if (year == 2026 || year == 2027) {
          currentDate = "$day-$month";
        }
      }
    } else if (line == 'END:VEVENT') {
      if (currentDate != null && currentSummary != null) {
        fetched[currentDate] = currentSummary.replaceAll("'", "\\'");
      }
      currentDate = null;
      currentSummary = null;
    }
  }
  
  print('final Map<String, String> _googleHolidays = {');
  fetched.forEach((k, v) {
    print("  '$k': '$v',");
  });
  print('};');
}
