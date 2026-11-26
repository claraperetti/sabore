import 'package:flutter_test/flutter_test.dart';

import 'package:sabore/utils/validacao.dart';

void main() {
  test('campo vazio pede para digitar o nome', () {
    expect(validarTermoPesquisa(''), contains('Digite o nome'));
    expect(validarTermoPesquisa(null), contains('Digite o nome'));
  });

  test('campo só com espaços explica como corrigir', () {
    expect(validarTermoPesquisa('    '), contains('só espaços'));
  });

  test('termo com texto é válido', () {
    expect(validarTermoPesquisa('  bolo '), isNull);
  });
}
