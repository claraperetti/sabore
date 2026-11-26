/// Uma receita do Saborê, montada a partir da API DummyJSON.
///
/// Campos que podem faltar na API são anuláveis (`int?`, `double?`):
/// `null` quer dizer "não informado", que é diferente de zero.
class Receita {
  const Receita({
    required this.id,
    required this.nome,
    required this.ingredientes,
    required this.instrucoes,
    this.imagemUrl,
    this.tempoPreparo,
    this.tempoCozimento,
    this.porcoes,
    this.dificuldade,
    this.culinaria,
    this.avaliacao,
    this.tiposRefeicao = const [],
  });

  final int id;
  final String nome;
  final String? imagemUrl;
  final List<String> ingredientes; // vazia = não informados
  final List<String> instrucoes; // vazia = não informadas; ordem preservada
  final int? tempoPreparo;
  final int? tempoCozimento;
  final int? porcoes;
  final String? dificuldade;
  final String? culinaria;
  final double? avaliacao; // de 0 a 5
  final List<String> tiposRefeicao;

  /// Tempo total, só quando preparo E cozimento foram informados.
  /// Somar só um deles daria um "total" enganoso.
  int? get tempoTotal => (tempoPreparo != null && tempoCozimento != null)
      ? tempoPreparo! + tempoCozimento!
      : null;

  /// Avaliação no formato brasileiro: "4,6 / 5".
  String? get avaliacaoTexto => avaliacao == null
      ? null
      : '${avaliacao!.toStringAsFixed(1).replaceAll('.', ',')} / 5';

  /// Linha curta usada nos cartões: "35 min · Fácil".
  String get resumo {
    final partes = [if (tempoTotal != null) '$tempoTotal min', ?dificuldade];
    return partes.isEmpty ? 'Detalhes não informados' : partes.join(' · ');
  }

  /// Cria uma receita a partir de um item JSON da API, VALIDANDO o
  /// tipo de cada campo antes de usá-lo.
  ///
  /// Só o `id` é obrigatório: sem ele não há como identificar a
  /// receita (nem evitar favoritos duplicados). Os outros campos com
  /// tipo errado ou ausentes viram "não informado".
  factory Receita.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const DadosInvalidosException('a receita não é um objeto JSON');
    }

    final id = json['id'];
    if (id is! int) {
      throw const DadosInvalidosException('"id" deveria ser um número inteiro');
    }

    final imagem = json['image'];

    return Receita(
      id: id,
      nome: _texto(json['name']) ?? 'Receita sem nome',
      imagemUrl: imagem is String && imagem.startsWith('http') ? imagem : null,
      ingredientes: _listaDeTextos(json['ingredients']),
      instrucoes: _listaDeTextos(json['instructions']),
      tempoPreparo: _minutos(json['prepTimeMinutes']),
      tempoCozimento: _minutos(json['cookTimeMinutes']),
      porcoes: _porcoes(json['servings']),
      dificuldade: _traduzirDificuldade(json['difficulty']),
      culinaria: _texto(json['cuisine']),
      avaliacao: _avaliacao(json['rating']),
      tiposRefeicao: _listaDeTextos(json['mealType']),
    );
  }

  /// Lê a resposta inteira da API ({"recipes": [...]}).
  ///
  /// Se o formato geral estiver errado, lança [DadosInvalidosException].
  /// Itens sem `id` válido são descartados, para que um item com
  /// problema não impeça os outros de aparecerem.
  static List<Receita> listaDoJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const DadosInvalidosException('a resposta não é um objeto JSON');
    }
    final itens = json['recipes'];
    if (itens is! List) {
      throw const DadosInvalidosException('"recipes" deveria ser uma lista');
    }

    final receitas = <Receita>[];
    for (final item in itens) {
      try {
        receitas.add(Receita.fromJson(item));
      } on DadosInvalidosException {
        // Item com dados inválidos: ignorado.
      }
    }
    return receitas;
  }
}

/// Erro lançado quando o JSON recebido não tem os tipos esperados.
class DadosInvalidosException implements Exception {
  const DadosInvalidosException(this.motivo);

  final String motivo;

  @override
  String toString() => 'Dados inválidos: $motivo';
}

String? _texto(Object? valor) =>
    valor is String && valor.trim().isNotEmpty ? valor.trim() : null;

/// Lista de textos. Se a API mandar um texto só em vez de lista,
/// vira uma lista de um item. Itens que não são texto são ignorados,
/// e a ordem é preservada.
List<String> _listaDeTextos(Object? valor) {
  if (valor is String) return [?_texto(valor)];
  if (valor is! List) return const [];
  return [for (final item in valor) ?_texto(item)];
}

/// Minutos: aceita qualquer número (int ou double) não negativo.
int? _minutos(Object? valor) =>
    valor is num && valor >= 0 ? valor.round() : null;

/// Porções: só é útil se for pelo menos 1.
int? _porcoes(Object? valor) =>
    valor is num && valor >= 1 ? valor.round() : null;

/// Avaliação: `num` pode chegar como int (5) ou double (4.6).
double? _avaliacao(Object? valor) =>
    valor is num && valor >= 0 && valor <= 5 ? valor.toDouble() : null;

String? _traduzirDificuldade(Object? valor) => switch (_texto(valor)) {
  'Easy' => 'Fácil',
  'Medium' => 'Média',
  'Hard' => 'Difícil',
  final outro => outro,
};
