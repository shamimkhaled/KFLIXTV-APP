import 'package:flutter_test/flutter_test.dart';

import 'package:kloud_tv/main.dart';

void main() {
  testWidgets('Home screen shows Kloud TV title and portal grid',
      (WidgetTester tester) async {
    await tester.pumpWidget(const KloudTvApp());
    await tester.pumpAndSettle();

    expect(find.text('Kloud TV'), findsOneWidget);
    expect(find.text('Circle FTP'), findsWidgets);
  });
}
