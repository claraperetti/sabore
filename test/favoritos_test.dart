import 'package:flutter_test/flutter_test.dart';

import 'package:sabore/data/receitas_exemplo.dart';
import 'package:sabore/state/favoritos.dart';

void main() {
  final bolo = receitasExemplo[0];
  final pizza = receitasExemplo[5];

  test('adicionar a mesma receita duas vezes não duplica', () {
    final favoritos = Favoritos();

    favoritos.adicionar(bolo);
    favoritos.adicionar(bolo);

    expect(favoritos.quantidade, 1);
    expect(favoritos.itens, [bolo]);
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
