import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:sabore/main.dart';

final campo = find.byKey(const Key('campoPesquisa'));
final botaoPesquisar = find.byKey(const Key('botaoPesquisar'));
final botaoFavoritos = find.byKey(const Key('botaoFavoritos'));

/// Abre o app numa tela do tamanho de um celular grande, para a
/// lista caber sem precisar rolar nos testes.
Future<void> abrirApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const SaboreApp());
}

Future<void> pesquisar(WidgetTester tester, String termo) async {
  await tester.enterText(campo, termo);
  await tester.tap(botaoPesquisar);
  await tester.pumpAndSettle();
}

void main() {
  group('Pesquisa', () {
    testWidgets('ao abrir, mostra o campo rotulado e todas as receitas', (
      tester,
    ) async {
      await abrirApp(tester);

      expect(find.text('Saborê'), findsOneWidget);
      expect(find.text('Nome da receita'), findsOneWidget);
      expect(find.text('Todas as receitas'), findsOneWidget);
      expect(find.text('Bolo de cenoura com chocolate'), findsOneWidget);
    });

    testWidgets('pesquisa vazia mostra mensagem de correção', (tester) async {
      await abrirApp(tester);

      await tester.tap(botaoPesquisar);
      await tester.pump();

      expect(
        find.textContaining('Digite o nome de uma receita'),
        findsOneWidget,
      );
      expect(find.textContaining('Você pesquisou'), findsNothing);
    });

    testWidgets('pesquisa só com espaços é recusada', (tester) async {
      await abrirApp(tester);

      await pesquisar(tester, '   ');

      expect(find.textContaining('só espaços'), findsOneWidget);
      expect(find.textContaining('Você pesquisou'), findsNothing);
    });

    testWidgets('pesquisa válida filtra a lista e permite nova busca', (
      tester,
    ) async {
      await abrirApp(tester);

      await pesquisar(tester, '  frango ');

      expect(find.text('Você pesquisou: “frango”'), findsOneWidget);
      expect(find.text('2 receitas encontradas.'), findsOneWidget);
      expect(find.text('Bolo de cenoura com chocolate'), findsNothing);

      await tester.tap(find.byKey(const Key('botaoNovaBusca')));
      await tester.pumpAndSettle();

      expect(find.text('Todas as receitas'), findsOneWidget);
      expect(tester.widget<TextFormField>(campo).controller!.text, isEmpty);
    });

    testWidgets('pesquisa sem resultados mostra mensagem própria', (
      tester,
    ) async {
      await abrirApp(tester);

      await pesquisar(tester, 'sushi');

      expect(find.byKey(const Key('semResultados')), findsOneWidget);
      expect(
        find.textContaining('Não achamos receitas com “sushi”'),
        findsOneWidget,
      );
    });
  });

  group('Navegação', () {
    testWidgets('detalhes mostram ingredientes e preparo, e voltar mantém '
        'a pesquisa', (tester) async {
      await abrirApp(tester);
      await pesquisar(tester, 'frango');

      await tester.tap(find.text('Strogonoff de frango'));
      await tester.pumpAndSettle();

      expect(find.text('Ingredientes'), findsOneWidget);
      expect(find.text('Modo de preparo'), findsOneWidget);
      expect(find.text('1 cebola picada'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // A pesquisa continua lá: termo, resultados e texto do campo.
      expect(find.text('Você pesquisou: “frango”'), findsOneWidget);
      expect(find.text('2 receitas encontradas.'), findsOneWidget);
      expect(tester.widget<TextFormField>(campo).controller!.text, 'frango');
    });
  });

  group('Favoritos', () {
    testWidgets('sem favoritas mostra mensagem de lista vazia', (tester) async {
      await abrirApp(tester);

      await tester.tap(botaoFavoritos);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('favoritosVazio')), findsOneWidget);
      expect(find.text('Nenhuma favorita ainda'), findsOneWidget);
    });

    testWidgets('favoritar nos detalhes aparece uma vez nos favoritos', (
      tester,
    ) async {
      await abrirApp(tester);

      await tester.tap(find.text('Pizza margherita'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('botaoFavoritarDetalhes')));
      await tester.pumpAndSettle();
      expect(find.text('Remover dos favoritos'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(botaoFavoritos);
      await tester.pumpAndSettle();

      expect(find.text('Minhas favoritas'), findsOneWidget);
      expect(find.text('Pizza margherita'), findsOneWidget);
      expect(find.byKey(const Key('favoritosVazio')), findsNothing);
    });

    testWidgets('desfavoritar na lista de favoritas volta ao estado vazio', (
      tester,
    ) async {
      await abrirApp(tester);

      await tester.tap(find.byKey(const ValueKey('favoritar-1')));
      await tester.pumpAndSettle();
      await tester.tap(botaoFavoritos);
      await tester.pumpAndSettle();
      expect(find.text('Bolo de cenoura com chocolate'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('favoritar-1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('favoritosVazio')), findsOneWidget);
    });
  });
}
