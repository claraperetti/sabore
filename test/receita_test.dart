import 'package:flutter_test/flutter_test.dart';

import 'package:sabore/models/receita.dart';

import 'dados_falsos.dart';

Map<String, dynamic> copiaCom(Map<String, dynamic> mudancas) => {
  ...(receitasJson[0] as Map<String, dynamic>),
  ...mudancas,
};

Map<String, dynamic> copiaSem(String campo) =>
    Map.of(receitasJson[0] as Map<String, dynamic>)..remove(campo);

void main() {
  group('Receita.fromJson', () {
    test('lê uma receita válida da API', () {
      final receita = Receita.fromJson(receitasJson[0]);

      expect(receita.id, 1);
      expect(receita.nome, 'Classic Margherita Pizza');
      expect(receita.ingredientes, hasLength(3));
      expect(receita.instrucoes, ['Preheat the oven.', 'Bake for 15 minutes.']);
      expect(receita.tempoTotal, 35); // preparo 20 + cozimento 15
      expect(receita.porcoes, 4);
      expect(receita.dificuldade, 'Fácil'); // "Easy" traduzido
      expect(receita.avaliacaoTexto, '4,6 / 5');
      expect(receita.tiposRefeicao, ['Dinner']);
      expect(receita.imagemUrl, startsWith('https://'));
    });

    test('recusa id que não é número inteiro', () {
      expect(
        () => Receita.fromJson(copiaCom({'id': '1'})),
        throwsA(isA<DadosInvalidosException>()),
      );
      expect(
        () => Receita.fromJson(copiaSem('id')),
        throwsA(isA<DadosInvalidosException>()),
      );
    });

    test('nome ausente ou com tipo errado vira "Receita sem nome"', () {
      expect(Receita.fromJson(copiaSem('name')).nome, 'Receita sem nome');
      expect(Receita.fromJson(copiaCom({'name': 42})).nome, 'Receita sem nome');
      expect(
        Receita.fromJson(copiaCom({'name': '   '})).nome,
        'Receita sem nome',
      );
    });

    test('ingredientes e instruções ausentes viram listas vazias', () {
      final receita = Receita.fromJson(
        copiaCom({'ingredients': null, 'instructions': 123}),
      );

      expect(receita.ingredientes, isEmpty);
      expect(receita.instrucoes, isEmpty);
    });

    test('ignora itens que não são texto e preserva a ordem', () {
      final receita = Receita.fromJson(
        copiaCom({
          'instructions': ['Passo 1', 3, null, '  ', 'Passo 2', 'Passo 3'],
        }),
      );

      expect(receita.instrucoes, ['Passo 1', 'Passo 2', 'Passo 3']);
    });

    test('tempo ausente NÃO vira zero, e o total só é calculado '
        'com os dois tempos', () {
      final semCozimento = Receita.fromJson(copiaSem('cookTimeMinutes'));
      expect(semCozimento.tempoPreparo, 20);
      expect(semCozimento.tempoCozimento, isNull);
      expect(semCozimento.tempoTotal, isNull);

      final tipoErrado = Receita.fromJson(copiaCom({'prepTimeMinutes': '20'}));
      expect(tipoErrado.tempoPreparo, isNull);
      expect(tipoErrado.tempoTotal, isNull);

      // Zero informado de verdade continua sendo zero.
      final zero = Receita.fromJson(copiaCom({'cookTimeMinutes': 0}));
      expect(zero.tempoTotal, 20);
    });

    test('porções só são usadas quando fazem sentido', () {
      expect(Receita.fromJson(copiaCom({'servings': 0})).porcoes, isNull);
      expect(
        Receita.fromJson(copiaCom({'servings': 'quatro'})).porcoes,
        isNull,
      );
      expect(Receita.fromJson(copiaCom({'servings': 6})).porcoes, 6);
    });

    test('rating é lido como num: int ou double', () {
      expect(Receita.fromJson(copiaCom({'rating': 5})).avaliacao, 5.0);
      expect(Receita.fromJson(copiaCom({'rating': 4.6})).avaliacao, 4.6);
      expect(Receita.fromJson(copiaCom({'rating': '4.6'})).avaliacao, isNull);
      expect(Receita.fromJson(copiaSem('rating')).avaliacaoTexto, isNull);
    });

    test('mealType é lista; um texto único também é aceito', () {
      expect(
        Receita.fromJson(
          copiaCom({
            'mealType': ['Lunch', 'Dinner'],
          }),
        ).tiposRefeicao,
        ['Lunch', 'Dinner'],
      );
      expect(Receita.fromJson(copiaCom({'mealType': 'Snack'})).tiposRefeicao, [
        'Snack',
      ]);
      expect(
        Receita.fromJson(copiaCom({'mealType': 7})).tiposRefeicao,
        isEmpty,
      );
    });

    test('campos opcionais com tipo errado ficam "não informados"', () {
      final receita = Receita.fromJson(
        copiaCom({'image': 123, 'difficulty': false, 'cuisine': ''}),
      );

      expect(receita.imagemUrl, isNull);
      expect(receita.dificuldade, isNull);
      expect(receita.culinaria, isNull);
    });
  });

  group('Receita.listaDoJson', () {
    test('descarta itens sem id válido e mantém os outros', () {
      final receitas = Receita.listaDoJson({'recipes': receitasJson});

      expect(receitas.map((r) => r.id), [1, 2, 3]);
    });

    test('recusa resposta sem a lista "recipes"', () {
      expect(
        () => Receita.listaDoJson({'recipes': 'nada'}),
        throwsA(isA<DadosInvalidosException>()),
      );
      expect(
        () => Receita.listaDoJson([1, 2, 3]),
        throwsA(isA<DadosInvalidosException>()),
      );
    });
  });
}
