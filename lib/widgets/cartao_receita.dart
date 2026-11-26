import 'package:material_ui/material_ui.dart';

import '../models/receita.dart';
import '../state/favoritos.dart';
import '../theme.dart';
import 'imagem_receita.dart';

/// Cartão de uma receita, usado na listagem e nos favoritos.
class CartaoReceita extends StatelessWidget {
  const CartaoReceita({
    super.key,
    required this.receita,
    required this.aoTocar,
  });

  final Receita receita;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final favoritos = FavoritosScope.of(context);
    final favorita = favoritos.contem(receita);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ImagemReceita(url: receita.imagemUrl, largura: 84, altura: 84),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receita.nome,
                      style: textos.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(receita.resumo, style: textos.bodyMedium),
                  ],
                ),
              ),
              IconButton(
                key: ValueKey('favoritar-${receita.id}'),
                tooltip: favorita
                    ? 'Remover dos favoritos'
                    : 'Adicionar aos favoritos',
                onPressed: () => favoritos.alternar(receita),
                icon: Icon(
                  favorita
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: AppColors.terracota,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
