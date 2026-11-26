import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:sabore/models/receita.dart';

/// Receitas no mesmo formato JSON que a DummyJSON devolve.
final receitasJson = <Object?>[
  {
    'id': 1,
    'name': 'Classic Margherita Pizza',
    'image': 'https://cdn.dummyjson.com/recipe-images/1.webp',
    'ingredients': ['Pizza dough', 'Tomato sauce', 'Fresh mozzarella'],
    'instructions': ['Preheat the oven.', 'Bake for 15 minutes.'],
    'prepTimeMinutes': 20,
    'cookTimeMinutes': 15,
    'servings': 4,
    'difficulty': 'Easy',
    'cuisine': 'Italian',
    'rating': 4.6,
    'mealType': ['Dinner'],
  },
  {
    'id': 2,
    'name': 'Chicken Alfredo Pasta',
    'image': 'https://cdn.dummyjson.com/recipe-images/2.webp',
    'ingredients': ['Fettuccine', 'Chicken breast', 'Heavy cream'],
    'instructions': ['Cook the pasta.', 'Cook the chicken.', 'Mix everything.'],
    'prepTimeMinutes': 15,
    'cookTimeMinutes': 20,
    'servings': 4,
    'difficulty': 'Medium',
    'cuisine': 'Italian',
    'rating': 5,
    'mealType': ['Lunch', 'Dinner'],
  },
  {
    'id': 3,
    'name': 'Mango Salsa Chicken',
    'image': 'https://cdn.dummyjson.com/recipe-images/3.webp',
    'ingredients': ['Chicken thighs', 'Mango'],
    'instructions': ['Grill the chicken.', 'Top with salsa.'],
    'prepTimeMinutes': 15,
    'cookTimeMinutes': 20,
    'servings': 3,
    'difficulty': 'Easy',
    'cuisine': 'Mexican',
    'rating': 4.4,
    'mealType': ['Dinner'],
  },
  // Item com tipo errado: o "id" é texto. Deve ser descartado.
  {
    'id': 'quatro',
    'name': 'Receita quebrada',
    'ingredients': <String>[],
    'instructions': <String>[],
  },
];

http.Response _respostaJson(Object json, [int status = 200]) =>
    http.Response.bytes(
      utf8.encode(jsonEncode(json)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

/// Cliente HTTP falso que imita a API.
///
/// [falhasAntes] faz os primeiros pedidos falharem como se não
/// houvesse internet, para testar o "Tentar novamente".
MockClient clienteFalso({int falhasAntes = 0}) {
  var falhasRestantes = falhasAntes;
  return MockClient((pedido) async {
    if (falhasRestantes > 0) {
      falhasRestantes--;
      throw http.ClientException('sem internet', pedido.url);
    }
    if (pedido.url.path == '/recipes') {
      return _respostaJson({'recipes': receitasJson});
    }
    if (pedido.url.path == '/recipes/search') {
      final termo = pedido.url.queryParameters['q']!.toLowerCase();
      final encontradas = receitasJson.where((item) {
        final nome = (item as Map)['name'];
        return nome is String && nome.toLowerCase().contains(termo);
      }).toList();
      return _respostaJson({'recipes': encontradas});
    }
    return _respostaJson({'message': 'not found'}, 404);
  });
}

/// Cliente que sempre responde com o corpo e o status indicados.
MockClient clienteQueResponde(String corpo, {int status = 200}) =>
    MockClient((_) async => http.Response(corpo, status));

/// Receita simples para testes que não envolvem a API.
Receita receitaTeste(int id, String nome) => Receita(
  id: id,
  nome: nome,
  ingredientes: const ['Ingrediente'],
  instrucoes: const ['Passo'],
  tempoPreparo: 5,
  tempoCozimento: 5,
  porcoes: 2,
  dificuldade: 'Fácil',
  culinaria: 'Brasileira',
);
