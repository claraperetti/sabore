import 'package:flutter_test/flutter_test.dart';

import 'package:sabore/main.dart';

void main() {
  testWidgets('Tela principal mostra o nome e os recursos do app', (
    tester,
  ) async {
    await tester.pumpWidget(const SaboreApp());

    expect(find.text('Saborê'), findsOneWidget);
    expect(find.text('O que vamos cozinhar hoje?'), findsOneWidget);
    expect(find.text('Pesquise pelo nome'), findsOneWidget);
  });
}
