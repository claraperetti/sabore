import 'package:material_ui/material_ui.dart';

import '../models/receita.dart';
import '../state/favoritos.dart';
import '../theme.dart';
import '../widgets/imagem_receita.dart';

/// Tela de detalhes: imagem, informações, ingredientes e preparo.
class DetalhesPage extends StatelessWidget {
  const DetalhesPage({super.key, required this.receita});

  final Receita receita;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final favoritos = FavoritosScope.of(context);
    final favorita = favoritos.contem(receita);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Barra que encolhe ao rolar, com a imagem de fundo.
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            backgroundColor: AppColors.creme,
            leading: const _Circulo(child: BackButton()),
            flexibleSpace: FlexibleSpaceBar(
              background: ImagemReceita(
                url: receita.imagemUrl,
                raio: 0,
                tamanhoIcone: 72,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            sliver: SliverList.list(
              children: [
                Text(
                  receita.nome,
                  style: textos.displaySmall?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Info(
                      icone: Icons.schedule_rounded,
                      texto: '${receita.tempoMinutos} min',
                    ),
                    _Info(
                      icone: Icons.people_alt_rounded,
                      texto: '${receita.porcoes} porções',
                    ),
                    _Info(
                      icone: Icons.local_fire_department_rounded,
                      texto: receita.dificuldade,
                    ),
                    _Info(
                      icone: Icons.public_rounded,
                      texto: receita.culinaria,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  key: const Key('botaoFavoritarDetalhes'),
                  onPressed: () => favoritos.alternar(receita),
                  icon: Icon(
                    favorita
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                  ),
                  label: Text(
                    favorita
                        ? 'Remover dos favoritos'
                        : 'Adicionar aos favoritos',
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: favorita
                        ? AppColors.terracotaEscuro
                        : AppColors.terracota,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text('Ingredientes', style: textos.titleLarge),
                const SizedBox(height: 8),
                for (final ingrediente in receita.ingredientes)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 8, right: 12),
                          child: Icon(
                            Icons.circle,
                            size: 7,
                            color: AppColors.acafrao,
                          ),
                        ),
                        Expanded(
                          child: Text(ingrediente, style: textos.bodyLarge),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 28),
                Text('Modo de preparo', style: textos.titleLarge),
                const SizedBox(height: 12),
                for (final (indice, passo) in receita.instrucoes.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.terracota,
                          child: Text(
                            '${indice + 1}',
                            style: const TextStyle(
                              color: AppColors.creme,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(passo, style: textos.bodyLarge)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fundo circular claro para o botão de voltar ficar visível
/// sobre qualquer imagem.
class _Circulo extends StatelessWidget {
  const _Circulo({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.creme.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: child,
      ),
    );
  }
}

/// Etiqueta com ícone e texto (tempo, porções...).
class _Info extends StatelessWidget {
  const _Info({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.papel,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF0E2D0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 16, color: AppColors.terracota),
          const SizedBox(width: 6),
          Text(
            texto,
            style: const TextStyle(
              color: AppColors.tinta,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
