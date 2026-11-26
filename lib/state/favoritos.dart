import 'package:material_ui/material_ui.dart';

import '../models/receita.dart';

/// Guarda as receitas favoritas enquanto o app está aberto.
///
/// As receitas ficam num Map indexado pelo id: o mesmo id nunca
/// entra duas vezes, então não existem duplicatas. O Map do Dart
/// mantém a ordem de inserção, então a lista sai na ordem em que
/// as receitas foram favoritadas.
class Favoritos extends ChangeNotifier {
  final Map<int, Receita> _porId = {};

  List<Receita> get itens => List.unmodifiable(_porId.values);
  int get quantidade => _porId.length;

  bool contem(Receita receita) => _porId.containsKey(receita.id);

  void adicionar(Receita receita) {
    if (contem(receita)) return; // já está nos favoritos
    _porId[receita.id] = receita;
    notifyListeners(); // avisa as telas para se redesenharem
  }

  void remover(Receita receita) {
    if (_porId.remove(receita.id) != null) notifyListeners();
  }

  void alternar(Receita receita) =>
      contem(receita) ? remover(receita) : adicionar(receita);
}

/// Disponibiliza os [Favoritos] para todas as telas.
///
/// Qualquer widget chama `FavoritosScope.of(context)` e é
/// redesenhado automaticamente quando os favoritos mudam.
class FavoritosScope extends InheritedNotifier<Favoritos> {
  const FavoritosScope({
    super.key,
    required Favoritos favoritos,
    required super.child,
  }) : super(notifier: favoritos);

  static Favoritos of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FavoritosScope>();
    assert(scope != null, 'FavoritosScope não encontrado acima deste widget.');
    return scope!.notifier!;
  }
}
