import 'package:flutter_test/flutter_test.dart';
import 'package:privacy_guard/app/privacy_guard_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows the Privacy Guard dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const PrivacyGuardApp());
    await tester.pumpAndSettle();

    expect(find.text('Privacy Guard'), findsOneWidget);
    expect(find.text('Smart privacy\nprotection'), findsOneWidget);
    expect(find.text('Shoulder-surfing detection'), findsOneWidget);
    expect(find.text('Enable guard'), findsOneWidget);
  });

  testWidgets('can enable the guard from the dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const PrivacyGuardApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enable guard'));
    await tester.pumpAndSettle();

    expect(find.text('Disable guard'), findsOneWidget);
    expect(find.text('Protection enabled'), findsOneWidget);
  });
}
