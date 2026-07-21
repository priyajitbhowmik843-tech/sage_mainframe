import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sage_mainframe/main.dart';
import 'package:sage_mainframe/state/app_state.dart';

void main() {
  testWidgets('App launches and shows login screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const SageMainframeApp(),
      ),
    );
    expect(find.text('SAGE MAINFRAME v2.0'), findsAtLeastNWidgets(1));
  });
}
