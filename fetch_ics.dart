import 'dart:io';
import 'dart:convert';

void main() async {
  var request = await HttpClient().getUrl(
    Uri.parse(
      'https://calendar.google.com/calendar/ical/en.indian%23holiday%40group.v.calendar.google.com/public/basic.ics',
    ),
  );
  var response = await request.close();
  var lines = await response
      .transform(utf8.decoder)
      .transform(LineSplitter())
      .toList();
  for (var line in lines) {
    if (line.startsWith('SUMMARY:')) {
      print(line);
    }
  }
}
