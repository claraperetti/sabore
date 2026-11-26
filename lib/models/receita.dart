/// Uma receita do Saborê.
///
/// Os campos seguem o que a API DummyJSON devolve (id, name, image,
/// ingredients, instructions...), para que a troca dos dados
/// provisórios pela API na entrega final seja simples.
class Receita {
  const Receita({
    required this.id,
    required this.nome,
    required this.ingredientes,
    required this.instrucoes,
    required this.tempoMinutos,
    required this.porcoes,
    required this.dificuldade,
    required this.culinaria,
    this.imagemUrl,
  });

  final int id;
  final String nome;
  final String? imagemUrl; // null = sem imagem (mostra um substituto)
  final List<String> ingredientes;
  final List<String> instrucoes;
  final int tempoMinutos;
  final int porcoes;
  final String dificuldade;
  final String culinaria;

  /// Linha curta usada nos cartões: "40 min · Fácil · Brasileira".
  String get resumo => '$tempoMinutos min · $dificuldade · $culinaria';
}
