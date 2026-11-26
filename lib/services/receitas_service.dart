import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/receita.dart';

/// Conversa com a API DummyJSON Recipes.
///
/// Toda falha vira um [ErroReceitas] com uma mensagem pronta para
/// mostrar na tela. Assim as telas não precisam conhecer detalhes de
/// rede, HTTP ou JSON.
class ReceitasService {
  /// O [client] pode ser trocado nos testes por um cliente falso.
  ReceitasService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _servidor = 'dummyjson.com';
  static const _tempoLimite = Duration(seconds: 12);
  // Pedimos só os campos que o app usa, para a resposta ficar menor.
  static const _campos =
      'id,name,image,ingredients,instructions,prepTimeMinutes,'
      'cookTimeMinutes,servings,difficulty,cuisine,rating,mealType';

  /// Todas as receitas (limit=0 pede a lista completa).
  Future<List<Receita>> listarTodas() => _buscarLista(
    Uri.https(_servidor, '/recipes', {'limit': '0', 'select': _campos}),
  );

  /// Pesquisa remota pelo nome da receita.
  Future<List<Receita>> buscarPorNome(String termo) => _buscarLista(
    Uri.https(_servidor, '/recipes/search', {
      'q': termo.trim(),
      'limit': '0',
      'select': _campos,
    }),
  );

  Future<List<Receita>> _buscarLista(Uri endereco) async {
    final http.Response resposta;
    try {
      resposta = await _client.get(endereco).timeout(_tempoLimite);
    } on TimeoutException {
      throw const ErroReceitas(
        'O servidor demorou demais para responder. '
        'Verifique sua internet e tente novamente.',
      );
    } on http.ClientException {
      throw const ErroReceitas(
        'Não foi possível conectar. Verifique se o celular está com '
        'internet e tente novamente.',
      );
    }

    if (resposta.statusCode != 200) {
      throw ErroReceitas(
        'O servidor de receitas respondeu com erro '
        '(código ${resposta.statusCode}). Tente novamente em instantes.',
      );
    }

    try {
      // utf8.decode garante que acentos e símbolos venham corretos.
      final json = jsonDecode(utf8.decode(resposta.bodyBytes));
      return Receita.listaDoJson(json);
    } on FormatException {
      throw const ErroReceitas(
        'Recebemos uma resposta ilegível do servidor. Tente novamente.',
      );
    } on DadosInvalidosException {
      throw const ErroReceitas(
        'Os dados recebidos vieram num formato inesperado. '
        'Tente novamente mais tarde.',
      );
    }
  }

  void fechar() => _client.close();
}

/// Falha ao carregar receitas, com mensagem para a pessoa usuária.
class ErroReceitas implements Exception {
  const ErroReceitas(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}
