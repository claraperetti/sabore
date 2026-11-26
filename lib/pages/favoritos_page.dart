import 'package:material_ui/material_ui.dart';

import '../state/favoritos.dart';
import '../theme.dart';
import '../widgets/cartao_receita.dart';
import 'detalhes_page.dart';

/// Aba "Favoritos": receitas salvas durante a sessão.
///
/// Lê a mesma instância de [Favoritos] que a aba Explorar e os
/// detalhes usam (fonte única de verdade), então qualquer mudança
/// aparece em todas as telas na hora.
class FavoritosPage extends StatelessWidget {
  const FavoritosPage({super.key, required this.aoExplorar});

  /// Volta para a aba Explorar.
  final VoidCallback aoExplorar;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final favoritas = FavoritosScope.of(context).itens;

    return SafeArea(
      child: favoritas.isEmpty
          ? _SemFavoritos(aoExplorar: aoExplorar)
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              children: [
                Text(
                  'Favoritos',
                  style: textos.displaySmall?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 4),
                Text('Receitas salvas nesta sessão.', style: textos.bodyMedium),
                const SizedBox(height: 20),
                for (final receita in favoritas) ...[
                  CartaoReceita(
                    receita: receita,
                    aoTocar: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => DetalhesPage(receita: receita),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 8),
                Text(
                  'Toque no coração para remover.',
                  style: textos.bodyMedium,
                ),
              ],
            ),
    );
  }
}

/// Mensagem para quando ainda não há favoritos.
class _SemFavoritos extends StatelessWidget {
  const _SemFavoritos({required this.aoExplorar});

  final VoidCallback aoExplorar;

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
            Text('Nenhum favorito', style: textos.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Marque uma receita como favorita para encontrá-la aqui. '
              'Os favoritos ficam salvos enquanto o app estiver aberto.',
              style: textos.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const Key('botaoExplorar'),
              onPressed: aoExplorar,
              icon: const Icon(Icons.restaurant_menu_rounded),
              label: const Text('Explorar receitas'),
            ),
          ],
        ),
      ),
    );
  }
}
