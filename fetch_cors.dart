import 'dart:io';
import 'dart:convert';

void main() async {
  var request = await HttpClient().getUrl(
    Uri.parse(
      'https://api.allorigins.win/raw?url=' +
          Uri.encodeComponent(
            'https://calendar.google.com/calendar/ical/en.indian%23holiday%40group.v.calendar.google.com/public/basic.ics',
          ),
    ),
  );
  var response = await request.close();
  var body = await response.transform(utf8.decoder).join();
  print(body.substring(0, 200));
}
