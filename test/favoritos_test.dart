import 'package:flutter_test/flutter_test.dart';

import 'package:sabore/state/favoritos.dart';

import 'dados_falsos.dart';

void main() {
  final bolo = receitaTeste(1, 'Bolo');
  final pizza = receitaTeste(2, 'Pizza');

  test('adicionar a mesma receita duas vezes não duplica', () {
    final favoritos = Favoritos();

    favoritos.adicionar(bolo);
    favoritos.adicionar(bolo);
    // Outro objeto, mas com o mesmo id: também não duplica.
    favoritos.adicionar(receitaTeste(1, 'Bolo'));

    expect(favoritos.quantidade, 1);
  });

  test('mantém a ordem em que as receitas foram favoritadas', () {
    final favoritos = Favoritos()
      ..adicionar(pizza)
      ..adicionar(bolo);

    expect(favoritos.itens, [pizza, bolo]);
  });

  test('alternar adiciona e depois remove', () {
    final favoritos = Favoritos();

    favoritos.alternar(bolo);
    expect(favoritos.contem(bolo), isTrue);

    favoritos.alternar(bolo);
    expect(favoritos.contem(bolo), isFalse);
    expect(favoritos.quantidade, 0);
  });

  test('avisa as telas só quando algo muda', () {
    final favoritos = Favoritos();
    var avisos = 0;
    favoritos.addListener(() => avisos++);

    favoritos.adicionar(bolo);
    favoritos.adicionar(bolo); // repetida: não muda nada
    favoritos.remover(pizza); // não estava lá: não muda nada

    expect(avisos, 1);
  });
}
