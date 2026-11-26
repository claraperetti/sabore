import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';

import 'package:sabore/main.dart';
import 'package:sabore/services/receitas_service.dart';

import 'dados_falsos.dart';

final campo = find.byKey(const Key('campoPesquisa'));
final botaoPesquisar = find.byKey(const Key('botaoPesquisar'));
final abaFavoritos = find.byKey(const Key('abaFavoritos'));
final abaExplorar = find.byKey(const Key('abaExplorar'));

/// Abre o app numa tela grande de celular, usando a API falsa, e
/// espera o carregamento inicial terminar.
Future<void> abrirApp(
  WidgetTester tester, {
  http.Client? cliente,
  bool esperar = true,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    SaboreApp(servico: ReceitasService(client: cliente ?? clienteFalso())),
  );
  if (esperar) await tester.pumpAndSettle();
}

Future<void> pesquisar(WidgetTester tester, String termo) async {
  await tester.enterText(campo, termo);
  await tester.tap(botaoPesquisar);
  await tester.pumpAndSettle();
}

String textoDoCampo(WidgetTester tester) =>
    tester.widget<TextFormField>(campo).controller!.text;

void main() {
  group('RF01/RF02/RF06 - Carregamento e listagem', () {
    testWidgets('mostra carregamento e depois a lista da API', (tester) async {
      await abrirApp(tester, esperar: false);

      // Primeiro quadro: esperando a API, com o botão desativado.
      expect(find.byKey(const Key('carregando')), findsOneWidget);
      expect(find.text('Carregando receitas...'), findsOneWidget);
      expect(
        tester.widget<ButtonStyleButton>(botaoPesquisar).onPressed,
        isNull,
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('carregando')), findsNothing);
      // 4 itens no JSON, 1 com id inválido descartado = 3.
      expect(
        find.text('3 receitas. Toque em uma para ver o preparo.'),
        findsOneWidget,
      );
      expect(find.text('Classic Margherita Pizza'), findsOneWidget);
      expect(find.text('4,6 / 5'), findsOneWidget);
      expect(find.text('Receita quebrada'), findsNothing);
      expect(
        tester.widget<ButtonStyleButton>(botaoPesquisar).onPressed,
        isNotNull,
      );
    });

    testWidgets('toques repetidos durante a busca fazem um pedido só', (
      tester,
    ) async {
      var pesquisas = 0;
      final normal = clienteFalso();
      final cliente = _ClienteEspiao(normal, (pedido) {
        if (pedido.url.path == '/recipes/search') pesquisas++;
      }, atraso: const Duration(seconds: 1));
      await abrirApp(tester, cliente: cliente);

      await tester.enterText(campo, 'chicken');
      await tester.tap(botaoPesquisar);
      await tester.pump(); // a busca começou, ainda sem resposta
      expect(
        tester.widget<ButtonStyleButton>(botaoPesquisar).onPressed,
        isNull,
      );
      await tester.tap(botaoPesquisar, warnIfMissed: false);
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.tap(botaoPesquisar, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(pesquisas, 1);
      expect(find.text('2 receitas encontradas.'), findsOneWidget);
    });
  });

  group('RF07 - Erros', () {
    testWidgets('falha mostra erro e "Tentar novamente" recarrega', (
      tester,
    ) async {
      await abrirApp(tester, cliente: clienteFalso(falhasAntes: 1));

      expect(find.byKey(const Key('erroCarregamento')), findsOneWidget);
      expect(
        find.text('Não foi possível carregar as receitas.'),
        findsOneWidget,
      );
      expect(find.textContaining('Não foi possível conectar'), findsOneWidget);

      await tester.tap(find.byKey(const Key('botaoTentarNovamente')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('erroCarregamento')), findsNothing);
      expect(find.text('Classic Margherita Pizza'), findsOneWidget);
    });

    testWidgets('erro na pesquisa: tentar novamente repete a pesquisa', (
      tester,
    ) async {
      // O 1º pedido (lista) funciona; o 2º (pesquisa) falha.
      var pedidos = 0;
      final normal = clienteFalso();
      final cliente = _ClienteEspiao(normal, (pedido) {
        if (++pedidos == 2) {
          throw http.ClientException('sem internet', pedido.url);
        }
      });
      await abrirApp(tester, cliente: cliente);

      await pesquisar(tester, 'chicken');
      expect(find.byKey(const Key('erroCarregamento')), findsOneWidget);

      await tester.tap(find.byKey(const Key('botaoTentarNovamente')));
      await tester.pumpAndSettle();

      expect(find.text('Resultados para “chicken”'), findsOneWidget);
      expect(find.text('2 receitas encontradas.'), findsOneWidget);
    });

    testWidgets('resposta com corpo incompatível mostra erro', (tester) async {
      await abrirApp(
        tester,
        cliente: clienteQueResponde('{"recipes": "nenhuma"}'),
      );

      expect(find.byKey(const Key('erroCarregamento')), findsOneWidget);
      expect(find.textContaining('formato inesperado'), findsOneWidget);
    });
  });

  group('RF03 - Pesquisa', () {
    testWidgets('pesquisa vazia mostra mensagem de correção', (tester) async {
      await abrirApp(tester);

      await tester.tap(botaoPesquisar);
      await tester.pump();

      expect(
        find.textContaining('Digite o nome de uma receita'),
        findsOneWidget,
      );
      expect(find.textContaining('Resultados para'), findsNothing);
    });

    testWidgets('pesquisa só com espaços é recusada', (tester) async {
      await abrirApp(tester);

      await pesquisar(tester, '   ');

      expect(find.textContaining('só espaços'), findsOneWidget);
      expect(find.textContaining('Resultados para'), findsNothing);
    });

    testWidgets('pesquisa remota tira espaços e "Limpar pesquisa" volta '
        'à listagem', (tester) async {
      await abrirApp(tester);

      await pesquisar(tester, '  chicken ');

      expect(find.text('Resultados para “chicken”'), findsOneWidget);
      expect(find.text('2 receitas encontradas.'), findsOneWidget);
      expect(find.text('Classic Margherita Pizza'), findsNothing);

      await tester.tap(find.byKey(const Key('botaoLimparPesquisa')));
      await tester.pumpAndSettle();

      expect(find.text('Receitas disponíveis'), findsOneWidget);
      expect(find.text('Classic Margherita Pizza'), findsOneWidget);
      expect(textoDoCampo(tester), isEmpty);
    });
  });

  group('RF08 - Ausência de resultados', () {
    testWidgets('busca sem resultados tem mensagem e ações próprias', (
      tester,
    ) async {
      await abrirApp(tester);

      await pesquisar(tester, 'feijoada');

      expect(find.byKey(const Key('semResultados')), findsOneWidget);
      expect(find.text('Nenhum resultado'), findsOneWidget);
      expect(find.byKey(const Key('erroCarregamento')), findsNothing);

      // "Alterar pesquisa" mantém o termo para ser editado.
      await tester.tap(find.byKey(const Key('botaoAlterarPesquisa')));
      await tester.pumpAndSettle();
      expect(textoDoCampo(tester), 'feijoada');

      // "Ver todas as receitas" volta à listagem.
      await tester.tap(find.byKey(const Key('botaoVerTodas')));
      await tester.pumpAndSettle();
      expect(find.text('Receitas disponíveis'), findsOneWidget);
    });

    testWidgets('favoritos vazios têm mensagem diferente', (tester) async {
      await abrirApp(tester);

      await tester.tap(abaFavoritos);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('favoritosVazio')), findsOneWidget);
      expect(find.text('Nenhum favorito'), findsOneWidget);
      expect(find.text('Nenhum resultado'), findsNothing);

      // "Explorar receitas" volta para a aba Explorar.
      await tester.tap(find.byKey(const Key('botaoExplorar')));
      await tester.pumpAndSettle();
      expect(find.text('Receitas disponíveis'), findsOneWidget);
    });
  });

  group('RF04/RF09 - Detalhes e navegação', () {
    testWidgets('detalhes mostram os dados, e voltar mantém a pesquisa', (
      tester,
    ) async {
      await abrirApp(tester);
      await pesquisar(tester, 'chicken');

      await tester.tap(find.text('Chicken Alfredo Pasta'));
      await tester.pumpAndSettle();

      expect(find.text('Ingredientes'), findsOneWidget);
      expect(find.text('Heavy cream'), findsOneWidget);
      expect(find.text('Modo de preparo'), findsOneWidget);
      expect(find.text('Cook the pasta.'), findsOneWidget);
      expect(find.text('35 min'), findsOneWidget); // tempo total
      expect(find.text('Lunch'), findsOneWidget); // mealType

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('Resultados para “chicken”'), findsOneWidget);
      expect(find.text('2 receitas encontradas.'), findsOneWidget);
      expect(textoDoCampo(tester), 'chicken');
    });

    testWidgets('trocar de aba não perde a pesquisa', (tester) async {
      await abrirApp(tester);
      await pesquisar(tester, 'chicken');

      await tester.tap(abaFavoritos);
      await tester.pumpAndSettle();
      await tester.tap(abaExplorar);
      await tester.pumpAndSettle();

      expect(find.text('Resultados para “chicken”'), findsOneWidget);
    });
  });

  group('RF05 - Favoritos', () {
    testWidgets('favoritar pelo cartão e pelos detalhes não duplica', (
      tester,
    ) async {
      await abrirApp(tester);

      // Favorita pelo coração do cartão...
      await tester.tap(find.byKey(const ValueKey('favoritar-1')));
      await tester.pumpAndSettle();
      // ...e os detalhes já mostram que está salva.
      await tester.tap(find.text('Classic Margherita Pizza'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Remover dos favoritos'), findsOneWidget);
      expect(find.text('Salva'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      await tester.tap(abaFavoritos);
      await tester.pumpAndSettle();

      expect(find.text('Classic Margherita Pizza'), findsOneWidget);
      expect(find.text('Receitas salvas nesta sessão.'), findsOneWidget);
    });

    testWidgets('favoritos continuam depois de uma nova pesquisa', (
      tester,
    ) async {
      await abrirApp(tester);

      await tester.tap(find.byKey(const ValueKey('favoritar-1')));
      await tester.pumpAndSettle();
      await pesquisar(tester, 'chicken');

      await tester.tap(abaFavoritos);
      await tester.pumpAndSettle();

      expect(find.text('Classic Margherita Pizza'), findsOneWidget);
    });

    testWidgets('remover na aba Favoritos volta ao estado vazio', (
      tester,
    ) async {
      await abrirApp(tester);

      await tester.tap(find.byKey(const ValueKey('favoritar-2')));
      await tester.pumpAndSettle();
      await tester.tap(abaFavoritos);
      await tester.pumpAndSettle();
      expect(find.text('Chicken Alfredo Pasta'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('favoritar-2')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('favoritosVazio')), findsOneWidget);
    });
  });
}

/// Repassa os pedidos ao cliente normal, avisando antes cada um.
/// O aviso pode lançar uma exceção para simular falha de rede.
class _ClienteEspiao extends http.BaseClient {
  _ClienteEspiao(this._normal, this._aoPedir, {this.atraso = Duration.zero});

  final http.Client _normal;
  final void Function(http.BaseRequest pedido) _aoPedir;

  /// Simula uma rede lenta.
  final Duration atraso;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest pedido) async {
    _aoPedir(pedido);
    await Future<void>.delayed(atraso);
    return _normal.send(pedido);
  }
}
