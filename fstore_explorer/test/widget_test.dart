import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fstore_explorer/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ProductFeedApp(),
      ),
    );

    expect(find.byType(ProductFeedApp), findsOneWidget);
  });
}