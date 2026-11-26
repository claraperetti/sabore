/// Valida o texto digitado no campo de pesquisa.
///
/// Retorna `null` quando o termo é válido, ou uma mensagem que
/// explica como corrigir. O `TextFormField` mostra essa mensagem
/// embaixo do campo automaticamente.
String? validarTermoPesquisa(String? valor) {
  if (valor == null || valor.isEmpty) {
    return 'Digite o nome de uma receita em inglês. Exemplo: pizza, chicken ou salad.';
  }
  // trim() remove espaços do começo e do fim. Se não sobrar nada,
  // a pessoa digitou só espaços.
  if (valor.trim().isEmpty) {
    return 'O campo tem só espaços. Apague-os e digite pelo menos uma '
        'letra, como "pasta".';
  }
  return null;
}
