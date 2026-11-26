import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:sabore/services/receitas_service.dart';

import 'dados_falsos.dart';

Matcher erroCom(String trecho) => throwsA(
  isA<ErroReceitas>().having((e) => e.mensagem, 'mensagem', contains(trecho)),
);

void main() {
  test('listarTodas devolve só as receitas válidas', () async {
    final servico = ReceitasService(client: clienteFalso());

    final receitas = await servico.listarTodas();

    expect(receitas, hasLength(3));
  });

  test('buscarPorNome envia o termo para a API', () async {
    Uri? enderecoPedido;
    final servico = ReceitasService(
      client: MockClient((pedido) async {
        enderecoPedido = pedido.url;
        return http.Response('{"recipes": []}', 200);
      }),
    );

    await servico.buscarPorNome('  pizza ');

    expect(enderecoPedido!.path, '/recipes/search');
    expect(enderecoPedido!.queryParameters['q'], 'pizza');
  });

  test('sem internet vira mensagem amigável', () {
    final servico = ReceitasService(client: clienteFalso(falhasAntes: 1));

    expect(servico.listarTodas(), erroCom('Não foi possível conectar'));
  });

  test('erro do servidor informa o código', () {
    final servico = ReceitasService(
      client: clienteQueResponde('erro', status: 500),
    );

    expect(servico.listarTodas(), erroCom('500'));
  });

  test('JSON ilegível vira ErroReceitas', () {
    final servico = ReceitasService(client: clienteQueResponde('<html>'));

    expect(servico.listarTodas(), erroCom('ilegível'));
  });

  test('JSON com formato inesperado vira ErroReceitas', () {
    final servico = ReceitasService(
      client: clienteQueResponde('{"recipes": "nenhuma"}'),
    );

    expect(servico.listarTodas(), erroCom('formato inesperado'));
  });
}
