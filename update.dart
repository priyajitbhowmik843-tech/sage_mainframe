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
  String mapContent = '';
  for (var k in sortedKeys) {
    String safeSummary = holidays[k]!.replaceAll("'", "\\'");
    mapContent += "        '$k': '$safeSummary',\n";
  }

  final newFetchFunc =
      '''  Future<void> _fetchGoogleHolidays() async {
    setState(() => _isLoadingHolidays = true);
    setState(() {
      _googleHolidays = {
$mapContent      };
    });
    if (mounted) setState(() => _isLoadingHolidays = false);
  }''';

  final ceoFile = File('lib/screens/ceo_dashboard.dart');
  var ceoContent = await ceoFile.readAsString();
  final ceoRegex = RegExp(
    r'  Future<void> _fetchGoogleHolidays\(\) async \{.*?if \(mounted\) setState\(\(\) => _isLoadingHolidays = false\);\s*\}',
    dotAll: true,
  );
  ceoContent = ceoContent.replaceAll(ceoRegex, newFetchFunc);
  await ceoFile.writeAsString(ceoContent);

  final cofFile = File('lib/screens/cofounder_dashboard.dart');
  var cofContent = await cofFile.readAsString();
  final cofRegex = RegExp(
    r'  Future<void> _fetchGoogleHolidays\(\) async \{.*?if \(mounted\) setState\(\(\) => _isLoadingHolidays = false\);\s*\}',
    dotAll: true,
  );
  // Wait, I messed up the regex for cofounder_dashboard in the previous run. It got replaced with the `ceo_dashboard` format now, because the previous run actually matched the old cofounder format and replaced it with newFetchFunc!
  // So now cofounder_dashboard has the newFetchFunc format!
  cofContent = cofContent.replaceAll(ceoRegex, newFetchFunc);
  await cofFile.writeAsString(cofContent);

  final dualFile = File('lib/screens/dual_role_dashboard.dart');
  var dualContent = await dualFile.readAsString();
  final dualRegex = RegExp(
    r'    final _googleHolidays = <String, String>\{.*?\};',
    dotAll: true,
  );
  final dualMapReplacement =
      '    final _googleHolidays = <String, String>{\n$mapContent    };';
  dualContent = dualContent.replaceAll(dualRegex, dualMapReplacement);
  await dualFile.writeAsString(dualContent);

  print('Updated ceo, cofounder, and dual role dashboards');
}
