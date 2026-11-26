import 'package:material_ui/material_ui.dart';

import '../state/favoritos.dart';
import '../theme.dart';
import '../widgets/cartao_receita.dart';
import 'detalhes_page.dart';

/// Lista das receitas favoritadas durante a sessão.
class FavoritosPage extends StatelessWidget {
  const FavoritosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritas = FavoritosScope.of(context).itens;

    return Scaffold(
      appBar: AppBar(title: const Text('Minhas favoritas')),
      body: favoritas.isEmpty
          ? const _SemFavoritas()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: favoritas.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final receita = favoritas[i];
                return CartaoReceita(
                  receita: receita,
                  aoTocar: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => DetalhesPage(receita: receita),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// Mensagem para quando ainda não há favoritas.
class _SemFavoritas extends StatelessWidget {
  const _SemFavoritas();

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          key: const Key('favoritosVazio'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.acafrao.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 44,
                color: AppColors.terracota,
              ),
            ),
            const SizedBox(height: 20),
            Text('Nenhuma favorita ainda', style: textos.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Toque no coração de uma receita para guardá-la aqui. '
              'Suas favoritas ficam salvas enquanto o app estiver aberto.',
              style: textos.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.restaurant_menu_rounded),
              label: const Text('Explorar receitas'),
            ),
          ],
        ),
      ),
    );
  }
}
