/// Receitas PROVISÓRIAS usadas enquanto o app ainda não está ligado
/// à API DummyJSON. Na entrega final esta lista sai do app.
const List<String> receitasExemplo = [
  'Bolo de cenoura com chocolate',
  'Bolo de fubá cremoso',
  'Frango assado com batatas',
  'Strogonoff de frango',
  'Lasanha à bolonhesa',
  'Pizza margherita',
  'Panqueca de carne moída',
  'Arroz de forno',
  'Salada de grão-de-bico',
  'Pão de queijo mineiro',
];

/// Filtra as receitas de exemplo pelo nome, sem diferenciar
/// maiúsculas de minúsculas.
List<String> buscarReceitasExemplo(String termo) {
  final busca = termo.trim().toLowerCase();
  return receitasExemplo
      .where((nome) => nome.toLowerCase().contains(busca))
      .toList();
}
