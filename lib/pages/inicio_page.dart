import 'package:material_ui/material_ui.dart';

import '../services/receitas_service.dart';
import '../state/favoritos.dart';
import 'favoritos_page.dart';
import 'home_page.dart';

/// Estrutura do app: abas Explorar e Favoritos na barra inferior.
///
/// O IndexedStack mantém as duas abas vivas ao mesmo tempo. Por isso,
/// trocar de aba não perde a pesquisa nem refaz o carregamento.
class InicioPage extends StatefulWidget {
  const InicioPage({super.key, required this.servico});

  final ReceitasService servico;

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  int _aba = 0;

  void _irPara(int aba) {
    FocusScope.of(context).unfocus();
    setState(() => _aba = aba);
  }

  @override
  Widget build(BuildContext context) {
    final quantidadeFavoritos = FavoritosScope.of(context).quantidade;

    return Scaffold(
      body: IndexedStack(
        index: _aba,
        children: [
          HomePage(servico: widget.servico),
          FavoritosPage(aoExplorar: () => _irPara(0)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: _irPara,
        destinations: [
          const NavigationDestination(
            key: Key('abaExplorar'),
            icon: Icon(Icons.search_rounded),
            label: 'Explorar',
          ),
          NavigationDestination(
            key: const Key('abaFavoritos'),
            icon: Badge(
              isLabelVisible: quantidadeFavoritos > 0,
              label: Text('$quantidadeFavoritos'),
              child: const Icon(Icons.favorite_border_rounded),
            ),
            selectedIcon: const Icon(Icons.favorite_rounded),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }
}
