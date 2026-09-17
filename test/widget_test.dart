import 'package:flutter_test/flutter_test.dart';
import 'package:renkli_kartlar/main.dart';

void main() {
  testWidgets('App loads test', (WidgetTester tester) async {
    await tester.pumpWidget(const RenkliKartlarApp());
    expect(find.text('Renkli Kartlar'), findsOneWidget);
  });
}
