import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:sabore/main.dart';

void main() {
  final campo = find.byKey(const Key('campoPesquisa'));
  final botao = find.byKey(const Key('botaoPesquisar'));

  testWidgets('tela principal mostra o nome e o campo rotulado', (
    tester,
  ) async {
    await tester.pumpWidget(const SaboreApp());

    expect(find.text('Saborê'), findsOneWidget);
    expect(find.text('Nome da receita'), findsOneWidget);
    expect(find.text('Pesquisar'), findsOneWidget);
  });

  testWidgets('pesquisa vazia mostra mensagem de correção', (tester) async {
    await tester.pumpWidget(const SaboreApp());

    await tester.tap(botao);
    await tester.pump();

    expect(find.textContaining('Digite o nome de uma receita'), findsOneWidget);
    expect(find.textContaining('Você pesquisou'), findsNothing);
  });

  testWidgets('pesquisa só com espaços é recusada', (tester) async {
    await tester.pumpWidget(const SaboreApp());

    await tester.enterText(campo, '   ');
    await tester.tap(botao);
    await tester.pump();

    expect(find.textContaining('só espaços'), findsOneWidget);
    expect(find.textContaining('Você pesquisou'), findsNothing);
  });

  testWidgets('pesquisa válida mostra o termo e permite nova busca', (
    tester,
  ) async {
    // Tela do tamanho de um celular, para o botão caber na tela.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SaboreApp());

    await tester.enterText(campo, '  frango ');
    await tester.tap(botao);
    await tester.pumpAndSettle();

    expect(find.text('Você pesquisou: “frango”'), findsOneWidget);
    expect(find.text('2 receitas encontradas.'), findsOneWidget);

    final novaBusca = find.byKey(const Key('botaoNovaBusca'));
    await tester.tap(novaBusca);
    await tester.pumpAndSettle();

    expect(find.textContaining('Você pesquisou'), findsNothing);
    expect(tester.widget<TextFormField>(campo).controller!.text, isEmpty);
  });
}
